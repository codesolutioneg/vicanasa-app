import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Enhanced Firebase Cloud Messaging (FCM) Service
/// Handles sending notifications to specific users, topics, and admin devices
class FcmService {
  String _accessToken = '';
  bool _isInitialized = false;
  
  // Project configuration
  static const String _projectId = 'hesham-tarekapp';
  static const String _serviceAccountPath = 'assets/hesham-tarekapp-firebase-adminsdk-fbsvc-85747e3c68.json';
  static const String _allDevicesTopic = 'allDevices';
  
  // FCM API endpoints
  String get _fcmApiUrl => 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  
  // Required scopes for FCM
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging'
  ];

  /// Initializes the FCM service with access token
  /// Must be called before using any other methods
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      print('🔄 Initializing FCM Service...');
      
      // Load the service account JSON file
      final serviceAccountJson = await rootBundle.loadString(_serviceAccountPath);
      
      // Parse the service account credentials
      final accountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );
      
      // Obtain access credentials
      final client = http.Client();
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        _scopes,
        client,
      );
      
      // Store the access token
      _accessToken = accessCredentials.accessToken.data;
      _isInitialized = true;
      
      print('✅ FCM Service initialized successfully');
      print('🔑 Access Token obtained: ${_accessToken.substring(0, 20)}...');
      
      return true;
    } catch (e) {
      print('❌ Error initializing FCM Service: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Checks if the service is initialized
  bool get isInitialized => _isInitialized;



  /// Sends a notification to all devices subscribed to the "allDevices" topic
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Optional additional data payload
  Future<bool> sendNotificationToAllDevices({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      print('⚠️ FCM Service not initialized. Call initialize() first.');
      return false;
    }

    try {
      print('📤 Sending notification to all devices...');
      
      // Format text for RTL support
      final formattedTitle = _formatRtlText(title);
      final formattedBody = _formatRtlText(body);

      // Send the notification
      final success = await _sendNotificationToTopic(
        topic: _allDevicesTopic,
        title: formattedTitle,
        body: formattedBody,
        data: data,
      );

      if (success) {
        print('✅ FCM Notification sent to all devices successfully!');
      } else {
        print('❌ Failed to send FCM notification to all devices');
      }

      return success;
    } catch (e) {
      print('❌ Error sending FCM notification to all devices: $e');
      return false;
    }
  }

  /// Sends a notification to a specific user by FCM token
  /// [token] - User's FCM token
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Optional additional data payload
  Future<bool> sendNotificationToUser({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      print('⚠️ FCM Service not initialized. Call initialize() first.');
      return false;
    }

    try {
      print('📤 Sending notification to user...');
      
      // Format text for RTL support
      final formattedTitle = _formatRtlText(title);
      final formattedBody = _formatRtlText(body);

      // Send the notification
      final success = await _sendNotificationToUser(
        token: token,
        title: formattedTitle,
        body: formattedBody,
        data: data,
      );

      if (success) {
        print('✅ FCM Notification sent to user successfully!');
      } else {
        print('❌ Failed to send FCM notification to user');
      }

      return success;
    } catch (e) {
      print('❌ Error sending FCM notification to user: $e');
      return false;
    }
  }

  /// Sends a notification to a specific topic
  /// [topic] - Topic name
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Optional additional data payload
  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      print('⚠️ FCM Service not initialized. Call initialize() first.');
      return false;
    }

    try {
      print('📤 Sending notification to topic: $topic');
      
      // Format text for RTL support
      final formattedTitle = _formatRtlText(title);
      final formattedBody = _formatRtlText(body);

      // Send the notification
      final success = await _sendNotificationToTopic(
        topic: topic,
        title: formattedTitle,
        body: formattedBody,
        data: data,
      );

      if (success) {
        print('✅ FCM Notification sent to topic successfully!');
      } else {
        print('❌ Failed to send FCM notification to topic');
      }

      return success;
    } catch (e) {
      print('❌ Error sending FCM notification to topic: $e');
      return false;
    }
  }


  /// Sends an FCM notification to a specific user token
  Future<bool> _sendNotificationToUser({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final payload = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
        'android': {
          'priority': 'high',
          'notification': {
            'sound': 'default',
            'channel_id': 'high_importance_channel',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
              'alert': {
                'title': title,
                'body': body,
              },
            },
          },
        },
      },
    };

    return await _sendFcmRequest(payload);
  }

  /// Sends an FCM notification to a specific topic
  Future<bool> _sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final payload = {
      'message': {
        'topic': topic,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
        'android': {
          'priority': 'high',
          'notification': {
            'sound': 'default',
            'channel_id': 'high_importance_channel',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
              'alert': {
                'title': title,
                'body': body,
              },
            },
          },
        },
      },
    };

    return await _sendFcmRequest(payload);
  }

  /// Sends an FCM request using the v1 API with automatic token refresh
  Future<bool> _sendFcmRequest(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(_fcmApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode(payload),
      );

      print('📡 FCM Response Status Code: ${response.statusCode}');
      print('📡 FCM Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh and retry once
        print('🔄 Access token expired, attempting to refresh...');
        final refreshSuccess = await refreshToken();
        
        if (refreshSuccess) {
          print('🔄 Token refreshed successfully, retrying FCM request...');
          // Retry the request with new token
          final retryResponse = await http.post(
            Uri.parse(_fcmApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: json.encode(payload),
          );
          
          print('📡 FCM Retry Response Status Code: ${retryResponse.statusCode}');
          print('📡 FCM Retry Response Body: ${retryResponse.body}');
          
          if (retryResponse.statusCode == 200) {
            print('✅ FCM request succeeded after token refresh');
            return true;
          } else {
            print('❌ FCM request failed even after token refresh: ${retryResponse.statusCode}');
            print('❌ Error details: ${retryResponse.body}');
            return false;
          }
        } else {
          print('❌ Failed to refresh access token');
          return false;
        }
      } else {
        print('❌ FCM request failed with status: ${response.statusCode}');
        print('❌ Error details: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending FCM request: $e');
      return false;
    }
  }

  /// Formats text for RTL (Right-to-Left) support
  /// Adds RLE (Right-to-Left Embedding) character for proper Arabic text alignment
  String _formatRtlText(String text) {
    if (text.isEmpty) return text;
    
    // Check if text contains Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(text)) {
      return '\u202B$text'; // Add RLE for RTL alignment
    }
    
    return text;
  }

  /// Refreshes the access token
  /// Useful when the token expires
  Future<bool> refreshToken() async {
    _isInitialized = false;
    return await initialize();
  }

  /// Gets the current project ID
  static String get projectId => _projectId;

  /// Gets the all devices topic name
  static String get allDevicesTopic => _allDevicesTopic;
}
