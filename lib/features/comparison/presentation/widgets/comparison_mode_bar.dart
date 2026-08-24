import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/comparison_mode.dart';

class ComparisonModeBar extends StatelessWidget {
  const ComparisonModeBar({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ComparisonMode mode;
  final ValueChanged<ComparisonMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ComparisonMode>(
      segments: [
        ButtonSegment(
          value: ComparisonMode.year,
          label: Text('Year', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        ButtonSegment(
          value: ComparisonMode.monthly,
          label: Text('Monthly', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        ButtonSegment(
          value: ComparisonMode.custom,
          label: Text('Custom', style: GoogleFonts.cairo(fontSize: 12)),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.textSecondary;
        }),
      ),
    );
  }
}
