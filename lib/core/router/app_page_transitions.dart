import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// iOS-style horizontal slide for shell routes.
CustomTransitionPage<T> iosSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubicEmphasized,
      ));
      return SlideTransition(position: offset, child: child);
    },
  );
}
