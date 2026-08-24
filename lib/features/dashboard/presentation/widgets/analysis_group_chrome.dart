import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';

class AnalysisGroupHeader extends StatelessWidget {
  const AnalysisGroupHeader({
    super.key,
    required this.code,
    required this.name,
    required this.total,
    required this.themeColor,
    required this.canSee,
    required this.locked,
    required this.headerSolid,
    this.percent,
  });

  final String code;
  final String name;
  final double total;
  final Color themeColor;
  final bool canSee;
  final bool locked;
  final bool headerSolid;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final bg = headerSolid ? themeColor : themeColor.withValues(alpha: 0.12);
    final fg = headerSolid ? Colors.white : themeColor;
    final badgeBg = headerSolid
        ? Colors.white.withValues(alpha: 0.22)
        : themeColor.withValues(alpha: 0.18);
    final amountBg = headerSolid ? Colors.white : themeColor;
    final amountFg = headerSolid ? themeColor : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: bg,
      child: Row(
        children: [
          if (code.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canSee || locked) ...[
                  const SizedBox(width: 6),
                  Icon(
                    canSee
                        ? CupertinoIcons.lock_open
                        : CupertinoIcons.lock_fill,
                    size: 13,
                    color: fg.withValues(alpha: 0.85),
                  ),
                ],
              ],
            ),
          ),
          if (percent != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: headerSolid ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${AppFormatters.percent1.format(percent!)}%',
                style: TextStyle(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: amountBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppFormatters.money(total),
              style: TextStyle(
                color: amountFg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisGroupFooter extends StatelessWidget {
  const AnalysisGroupFooter({
    super.key,
    required this.label,
    required this.total,
    required this.themeColor,
    this.percent,
  });

  final String label;
  final double total;
  final Color themeColor;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: themeColor.withValues(alpha: 0.12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          if (percent != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${AppFormatters.percent1.format(percent!)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            AppFormatters.money(total),
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
