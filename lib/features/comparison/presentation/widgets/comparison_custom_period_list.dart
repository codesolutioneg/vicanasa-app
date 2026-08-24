import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/comparison_period.dart';
import '../../domain/comparison_period_rules.dart';

/// Custom period list + add button for a selected scope year.
class ComparisonCustomPeriodList extends StatelessWidget {
  const ComparisonCustomPeriodList({
    super.key,
    required this.scopeYear,
    required this.customPeriods,
    required this.onAddCustom,
    required this.onRemoveCustom,
  });

  final int scopeYear;
  final List<ComparisonPeriod> customPeriods;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onRemoveCustom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in customPeriods)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              p.label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${ComparisonPeriodRules.inclusiveDayCount(p.dateFrom, p.dateTo)} days',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(CupertinoIcons.trash, size: 18),
              onPressed: () => onRemoveCustom(p.id),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddCustom,
            icon: const Icon(CupertinoIcons.plus, size: 16),
            label: Text(
              'Add period in $scopeYear',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
