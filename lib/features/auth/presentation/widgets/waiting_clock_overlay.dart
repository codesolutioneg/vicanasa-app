import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WaitingClockOverlay extends StatefulWidget {
  const WaitingClockOverlay({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  State<WaitingClockOverlay> createState() => _WaitingClockOverlayState();
}

class _WaitingClockOverlayState extends State<WaitingClockOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final Stopwatch _watch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _watch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  String _elapsed() {
    final seconds = _watch.elapsed.inSeconds;
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Material(
          color: AppColors.bgSecondary,
          elevation: 8,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _spin,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(112, 112),
                        painter: _ClockPainter(progress: _spin.value),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _elapsed(),
                    style: AppTextStyles.headlineMd.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppColors.primaryMid,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSm,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final ring = Paint()
      ..color = AppColors.primaryPale
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, ring);

    final sweep = Paint()
      ..shader = SweepGradient(
        colors: const [AppColors.primaryLight, AppColors.primaryDark],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ((progress % 1.0) * 0.85 + 0.15),
      false,
      sweep,
    );

    final face = Paint()..color = AppColors.bgSecondary;
    canvas.drawCircle(center, radius - 10, face);

    final tick = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final inner = Offset(
        center.dx + math.cos(angle - math.pi / 2) * (radius - 22),
        center.dy + math.sin(angle - math.pi / 2) * (radius - 22),
      );
      final outer = Offset(
        center.dx + math.cos(angle - math.pi / 2) * (radius - 14),
        center.dy + math.sin(angle - math.pi / 2) * (radius - 14),
      );
      canvas.drawLine(inner, outer, tick);
    }

    final secondAngle = progress * 2 * math.pi - math.pi / 2;
    final minuteAngle = progress * 2 * math.pi / 8 - math.pi / 2;

    final minuteHand = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(minuteAngle) * (radius - 28),
        center.dy + math.sin(minuteAngle) * (radius - 28),
      ),
      minuteHand,
    );

    final secondHand = Paint()
      ..color = AppColors.primaryMid
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(secondAngle) * (radius - 20),
        center.dy + math.sin(secondAngle) * (radius - 20),
      ),
      secondHand,
    );

    canvas.drawCircle(center, 5, Paint()..color = AppColors.primaryDark);
    canvas.drawCircle(center, 2.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
