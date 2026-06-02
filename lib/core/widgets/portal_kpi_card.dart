import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_formatters.dart';

/// KPI tile matching the Partner Financial Portal web mockup.
class PortalKpiCard extends StatelessWidget {
  const PortalKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.subtitle,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String? subtitle;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.kpiLabel.copyWith(
                        letterSpacing: 0.6,
                        fontSize: 10.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: iconColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppFormatters.money(value),
                      style: AppTextStyles.kpiValue.copyWith(
                        fontSize: 20,
                        color: valueColor ?? AppColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
