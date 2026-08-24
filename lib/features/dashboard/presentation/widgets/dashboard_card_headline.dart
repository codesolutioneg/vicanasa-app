import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bold card/section title with a thin underline beneath.
class DashboardCardHeadline extends StatelessWidget {
  const DashboardCardHeadline({
    super.key,
    required this.text,
    this.color,
    this.trailing,
    this.fontSize = 11,
  });

  final String text;
  final Color? color;
  final Widget? trailing;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Color ink = color ?? AppColors.textPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.kpiLabel.copyWith(
                  letterSpacing: 0.6,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 1.5,
          color: ink.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}
