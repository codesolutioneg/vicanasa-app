import 'firebase_messaging_service.dart';

export 'firebase_messaging_service.dart';
export 'local_notifications_service.dart';

/// No-op on web; FCM on mobile.
Future<void> initNotifications() async {
  await FirebaseMessagingService.instance.init();
}
