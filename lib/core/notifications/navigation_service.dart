import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Routes FCM notification taps to app screens.
abstract final class NavigationService {
  static final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  static void handleFCMNotification(
    Map<String, dynamic> data, {
    bool isFromKilledState = false,
  }) {
    final ctx = rootKey.currentContext;
    if (ctx == null) return;
    final route = data['route'] as String? ?? '/dashboard';
    if (isFromKilledState) {
      Future.microtask(() => ctx.go(route));
    } else {
      ctx.go(route);
    }
  }
}
