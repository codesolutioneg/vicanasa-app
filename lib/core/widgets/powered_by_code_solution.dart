import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// Footer credit: Powered by Code Solution.
class PoweredByCodeSolution extends StatelessWidget {
  const PoweredByCodeSolution({super.key, this.compact = false});

  final bool compact;

  static const String _labelEn = 'Powered by CodeSolution';
  static const String _labelAr = 'مدعوم من CodeSolution';

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final label = isAr ? _labelAr : _labelEn;
    final logoHeight = compact ? 45.0 : 45.0;
    final fontSize = compact ? 11.0 : 12.0;
    final fg = AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),         SizedBox(width: compact ? 6 : 8),
 Image.asset(
          AppAssets.codeSolutionLogo,
          height: logoHeight,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => SizedBox(
            height: logoHeight,
            width: logoHeight,
            child: Center(
              child: Text(
                'CS',
                style: TextStyle(
                  fontSize: logoHeight * 0.45,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMid,
                ),
              ),
            ),
          ),
        ),
      
      ],
    );
  }
}
