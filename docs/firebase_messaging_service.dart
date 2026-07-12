import 'dart:developer';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hesham_tarek/core/services/navigation_service.dart';
import 'package:hesham_tarek/services/local_notifications_service.dart';
import 'package:permission_handler/permission_handler.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;

  Future<void> init(
      {required LocalNotificationsService localNotificationsService}) async {
    print('FCM flow: init started');
    _localNotificationsService = localNotificationsService;

    // Request user permission for notifications
    await _requestPermission();

    // Set foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle FCM token
    await _handlePushNotificationsToken();

    // Register handler for background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('FCM flow: background handler registered');

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background (not killed)
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      print(
        'FCM flow: onMessageOpenedApp fired, '
        'messageId=${m.messageId}, sentTime=${m.sentTime}, data=${m.data}',
      );
      _onMessageOpenedApp(m, isFromKilledState: false);
    });

    // Check for initial message that opened the app (e.g. app was killed, user tapped notification)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    print(
      'FCM flow: getInitialMessage resolved, '
      'hasMessage=${initialMessage != null}, messageId=${initialMessage?.messageId}, data=${initialMessage?.data}',
    );
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage, isFromKilledState: true);
    }
    print('FCM flow: init completed');
  }

  /// ----------- functions to handle Push Notifications token -----------
  String? taken;

  /// Get current FCM token
  /// Returns the token if available, or empty string if null
  Future<String> getFCMToken() async {
    try {
      if (taken != null && taken != "-" && taken!.isNotEmpty) {
        return taken!;
      }
      
      // Try to get token directly
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        taken = token;
        return token;
      }
      
      return "";
    } catch (e) {
      log('Error getting FCM token: $e');
      return "";
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    try {
      // For iOS, check if we have APNS token first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        taken = apnsToken ?? '-';
        if (apnsToken == null) {
          log('APNS token not yet available, will retry later');
          // Set up a listener for when the token becomes available
          FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
            taken = fcmToken ?? "-";
            log('FCM token received after APNS token available: $fcmToken');
            // TODO: Send token to your server
          });
          return;
        }
      }

      // If we get here, either we're not on iOS or APNS token is available
      final token = await FirebaseMessaging.instance.getToken();
      taken = token ?? "-";
      log('Push notifications token: $token');

      ///make all users subscribe to this topic allDevices
      subscribeToTopic('allDevices');
      subscribeToTopic('alldevices');
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        log('FCM token refreshed: $fcmToken');
        // TODO: Send token to your server if necessary
      }).onError((error) {
        log('Error refreshing FCM token: $error');
      });
    } catch (e) {
      log('Error getting FCM token: $e');
      // Retry after a delay if needed
      await Future.delayed(const Duration(seconds: 5));
      _handlePushNotificationsToken();
    }
  }

  /// ---------- functions to subscribe to topics and unsubscribe from topics -----------
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      log('Successfully subscribed to topic: $topic');
    } catch (e) {
      log('Failed to subscribe to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Failed to unsubscribe from topic $topic: $e');
    }
  }

  ///  ----------- functions to handle foreground and background messages -----------
  Future<void> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (await DeviceInfoPlugin()
              .androidInfo
              .then((info) => info.version.sdkInt) >=
          33) {
        final status = await Permission.notification.request();
        log('Android notification permission status: $status');
      }
      return;
    }

    // iOS permission handling
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('User granted permission: ${result.authorizationStatus}');
  }

  void _onForegroundMessage(RemoteMessage message) {
    print(
      'FCM flow: foreground message received, '
      'messageId=${message.messageId}, sentTime=${message.sentTime}, data=${message.data}',
    );
    final notificationData = message.notification;
    if (notificationData != null) {
      final payload = jsonEncode(message.data);
      print('FCM flow: showing local notification with payload=$payload');
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        payload,
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message, {bool isFromKilledState = false}) {
    if (message.data.isNotEmpty) {
      print(
        'FCM flow: notification opened app, '
        'isFromKilledState=$isFromKilledState, messageId=${message.messageId}, data=${message.data}',
      );
      NavigationService.handleFCMNotification(
        message.data,
        isFromKilledState: isFromKilledState,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
    'FCM flow: background handler message received, '
    'messageId=${message.messageId}, sentTime=${message.sentTime}, data=${message.data}',
  );
}
