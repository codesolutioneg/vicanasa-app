import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';

/// Shared hero column: title, then name / value lines, then total.
class DashboardHeroBranchColumn extends StatelessWidget {
  const DashboardHeroBranchColumn({
    super.key,
    required this.title,
    required this.icon,
    required this.lines,
    required this.total,
    required this.lineBuilder,
  });

  final String title;
  final IconData icon;
  final List<BranchShareLine> lines;
  final double total;
  final Widget Function(BranchShareLine line) lineBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.75)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 1.5,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 8),
        if (lines.isEmpty)
          Text(
            AppFormatters.money(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
        else ...[
          for (final line in lines) ...[
            lineBuilder(line),
            const SizedBox(height: 8),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            height: 1,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          Text(
            AppFormatters.money(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

/// Name on top, `9.4% = 768,372.55` under.
Widget heroShareLine(BranchShareLine line) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        line.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.80),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '${AppFormatters.percent1.format(line.sharePercentage)}% = ${AppFormatters.money(line.branchShare)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.98),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

/// Name on top, revenue amount under (same sequence as share).
Widget heroRevenueLine(BranchShareLine line) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        line.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.80),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        AppFormatters.money(line.revenue),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.98),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}
