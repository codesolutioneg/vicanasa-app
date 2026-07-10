import '../firebase/firebase_bootstrap.dart';
import 'firebase_messaging_service.dart';

export 'firebase_messaging_service.dart';
export 'local_notifications_service.dart';

/// No-op on web or when Firebase is not configured.
Future<void> initNotifications() async {
  if (!FirebaseBootstrap.isReady) return;
  await FirebaseMessagingService.instance.init();
}
