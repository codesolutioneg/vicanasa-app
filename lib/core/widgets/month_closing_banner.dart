import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class MonthClosingBanner extends StatelessWidget {
  const MonthClosingBanner({super.key, required this.period});

  final String period;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        border: const Border(
          left: BorderSide(color: AppColors.warningBorder, width: 3),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: AppColors.warningBorder,
            size: 16,
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(
              'Data is available until $period',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
