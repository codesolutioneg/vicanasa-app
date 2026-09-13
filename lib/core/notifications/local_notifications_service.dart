import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/constants.dart';
import 'navigation_service.dart';

class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService instance = LocalNotificationsService._();

  late FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int _id = 0;

  static const _androidChannel = AndroidNotificationChannel(
    AppConstants.fcmAndroidChannelId,
    'High Importance Notifications',
    description: 'Financial portal push notifications',
    importance: Importance.max,
  );

  static const _legacyChannel = AndroidNotificationChannel(
    'vacansa_channel',
    'Vicanza Notifications',
    description: 'Legacy Vicanza notification channel',
    importance: Importance.max,
  );

  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    _plugin = FlutterLocalNotificationsPlugin();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        NavigationService.handleFCMNotification(
          _parsePayload(r.payload),
          isFromKilledState: false,
        );
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      NavigationService.handleFCMNotification(
        _parsePayload(launch!.notificationResponse?.payload),
        isFromKilledState: true,
      );
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_androidChannel);
    await android?.createNotificationChannel(_legacyChannel);
    _initialized = true;
  }

  Map<String, dynamic> _parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return {};
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry('$k', v));
      }
    } catch (_) {}
    return {};
  }

  Future<void> show(String? title, String? body, String? payload) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      _id++,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
