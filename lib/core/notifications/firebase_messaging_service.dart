import 'dart:async';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/env.dart';
import '../firebase/firebase_bootstrap.dart';
import '../../firebase_options.dart';
import '../utils/email_topic_sanitizer.dart';
import 'local_notifications_service.dart';
import 'navigation_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger().i(
    'FCM background message received: id=${message.messageId}, '
    'title=${message.notification?.title}, body=${message.notification?.body}, '
    'from=${message.from}, data=${message.data}',
  );
}

/// FCM topic subscriptions — mobile only; no-op when Firebase/FCM is unavailable.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final _log = Logger();
  final Set<String> _topics = <String>{};
  String? _emailTopic;
  String? _pendingLoginEmail;
  bool _enabled = false;

  bool get isEnabled => _enabled;

  /// Logs the APNs and FCM tokens. On iOS the APNs token confirms that the
  /// device registered with Apple — without it, FCM cannot deliver push.
  Future<void> logFcmToken() async {
    if (kIsWeb || !FirebaseBootstrap.isReady) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken != null) {
          _log.i('APNs token: $apnsToken');
        } else {
          _log.w(
            'APNs token: NULL — device did not register with Apple. '
            'Check: signing team matches Firebase APNs key, Push '
            'Notifications capability, aps-environment entitlement, '
            'and run on a real device (not Simulator).',
          );
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _log.i('FCM token: $token');
      } else {
        _log.w('FCM token: not available yet');
      }
    } catch (e, st) {
      _log.w('FCM token fetch failed', error: e, stackTrace: st);
    }
  }

  /// iOS returns the APNs token asynchronously after registration; poll briefly.
  Future<String?> _waitForApnsToken({
    int attempts = 5,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (var i = 0; i < attempts; i++) {
      final token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null) return token;
      if (i < attempts - 1) await Future<void>.delayed(delay);
    }
    return null;
  }

  Future<void> init() async {
    if (kIsWeb || !FirebaseBootstrap.isReady) return;
    try {
      await LocalNotificationsService.instance.init();
      await _requestPermission();
      await logFcmToken();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => _onOpened(m, killed: false),
      );
      FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
      _enabled = true;
      await _subscribe(Env.fcmTopicDevelopment);
      if (_pendingLoginEmail != null) {
        final email = _pendingLoginEmail!;
        _pendingLoginEmail = null;
        await subscribeUserTopics(email);
      }
      _log.i('FCM ready (topic: ${Env.fcmTopicDevelopment})');
    } catch (e, st) {
      _enabled = false;
      _log.w('FCM init skipped — app continues without push', error: e, stackTrace: st);
      return;
    }
    await _configurePresentationAndInitialMessage();
  }

  /// These iOS method-channel calls can be slow to resolve, so they run after
  /// topic subscription and never block push registration.
  Future<void> _configurePresentationAndInitialMessage() async {
    try {
      unawaited(
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        ),
      );
      final initial = await FirebaseMessaging.instance
          .getInitialMessage()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (initial != null) _onOpened(initial, killed: true);
    } catch (e, st) {
      _log.w('FCM post-init step skipped', error: e, stackTrace: st);
    }
  }

  Future<void> subscribeUserTopics(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty) return;
    if (!_enabled) {
      _pendingLoginEmail = normalized;
      return;
    }
    await _subscribe(Env.fcmTopicAllUsers);
    final topic = sanitizeEmailForTopic(normalized);
    if (_emailTopic != null && _emailTopic != topic) {
      await _unsubscribe(_emailTopic!);
    }
    _emailTopic = topic;
    await _subscribe(topic);
  }

  Future<void> unsubscribeUserTopics() async {
    if (!_enabled) {
      _pendingLoginEmail = null;
      return;
    }
    await _unsubscribe(Env.fcmTopicAllUsers);
    if (_emailTopic != null) {
      await _unsubscribe(_emailTopic!);
      _emailTopic = null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb || !_enabled) return;
    await _subscribe(topic);
  }

  Future<void> _subscribe(String topic) async {
    if (kIsWeb) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _topics.add(topic);
      _log.i('Subscribed to $topic');
    } catch (e) {
      _log.w('Subscribe failed: $topic', error: e);
    }
  }

  /// On iOS the first subscribe may run before the FCM/APNs token is fully
  /// registered, so the server never records it. Re-subscribing on token
  /// refresh guarantees active topics stick once registration completes.
  Future<void> _onTokenRefresh(String token) async {
    if (_topics.isEmpty) return;
    _log.i('FCM token refreshed — re-subscribing to ${_topics.length} topic(s)');
    for (final topic in _topics.toList()) {
      await _subscribe(topic);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb || !_enabled) return;
    await _unsubscribe(topic);
  }

  Future<void> _unsubscribe(String topic) async {
    if (kIsWeb) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      _topics.remove(topic);
      _log.i('Unsubscribed from $topic');
    } catch (e) {
      _log.w('Unsubscribe failed: $topic', error: e);
    }
  }

  Future<void> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        await Permission.notification.request();
      }
      return;
    }
    final settings = await FirebaseMessaging.instance.requestPermission();
    _log.i('Notification permission: ${settings.authorizationStatus.name}');
  }

  void _onForeground(RemoteMessage message) {
    _log.i(
      'FCM foreground message received: id=${message.messageId}, '
      'title=${message.notification?.title}, body=${message.notification?.body}, '
      'from=${message.from}, data=${message.data}',
    );
    final n = message.notification;
    if (n != null) {
      LocalNotificationsService.instance.show(
        n.title,
        n.body,
        jsonEncode(message.data),
      );
      return;
    }
    if (message.data.isNotEmpty) {
      _log.i('FCM data-only message: ${message.data}');
    }
  }

  void _onOpened(RemoteMessage message, {required bool killed}) {
    if (message.data.isNotEmpty) {
      NavigationService.handleFCMNotification(
        message.data,
        isFromKilledState: killed,
      );
    }
  }
}
