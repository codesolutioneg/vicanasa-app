import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/env.dart';
import '../firebase/firebase_bootstrap.dart';
import '../utils/email_topic_sanitizer.dart';
import 'local_notifications_service.dart';
import 'navigation_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// FCM topic subscriptions — mobile only; no-op when Firebase/FCM is unavailable.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final _log = Logger();
  String? _emailTopic;
  bool _enabled = false;

  bool get isEnabled => _enabled;

  Future<void> init() async {
    if (kIsWeb || !FirebaseBootstrap.isReady) return;
    try {
      await LocalNotificationsService.instance.init();
      await _requestPermission();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => _onOpened(m, killed: false),
      );
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _onOpened(initial, killed: true);
      await subscribeToTopic(Env.fcmTopicAllUsers);
      _enabled = true;
      _log.i('FCM ready');
    } catch (e, st) {
      _enabled = false;
      _log.w('FCM init skipped — app continues without push', error: e, stackTrace: st);
    }
  }

  Future<void> subscribeUserTopics(String email) async {
    if (!_enabled) return;
    await subscribeToTopic(Env.fcmTopicAllUsers);
    final topic = sanitizeEmailForTopic(email);
    if (_emailTopic != null && _emailTopic != topic) {
      await unsubscribeFromTopic(_emailTopic!);
    }
    _emailTopic = topic;
    await subscribeToTopic(topic);
  }

  Future<void> unsubscribeUserTopic() async {
    if (!_enabled || _emailTopic == null) return;
    await unsubscribeFromTopic(_emailTopic!);
    _emailTopic = null;
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb || !_enabled) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _log.i('Subscribed to $topic');
    } catch (e) {
      _log.w('Subscribe failed: $topic', error: e);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb || !_enabled) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
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
    await FirebaseMessaging.instance.requestPermission();
  }

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n != null) {
      LocalNotificationsService.instance.show(
        n.title,
        n.body,
        jsonEncode(message.data),
      );
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
