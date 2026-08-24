import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../dashboard/presentation/widgets/analysis_permission.dart';

/// One account group — expands to account names when analysis level allows.
class PnlGroupTile extends StatelessWidget {
  const PnlGroupTile({
    super.key,
    required this.group,
    required this.accent,
    required this.analysisLevel,
    required this.allowedGroupIds,
  });

  final Map<String, dynamic> group;
  final Color accent;
  final String analysisLevel;
  final List<int> allowedGroupIds;

  TextStyle _cairo({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.cairo(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupId = (group['group_id'] as num?)?.toInt();
    final name = '${group['group_name'] ?? 'Group'}'.trim();
    final total = (group['total_amount'] as num?)?.toDouble() ?? 0;
    final accounts = (group['accounts'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final canSee = canSeeGroupDetails(
      analysisLevel: analysisLevel,
      allowedGroupIds: allowedGroupIds,
      groupId: groupId,
    );
    final locked = showGroupLockIcon(
      analysisLevel: analysisLevel,
      canSeeDetails: canSee,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          enabled: canSee && accounts.isNotEmpty,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _cairo(size: 14, weight: FontWeight.w700),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  AppFormatters.money(total),
                  style: _cairo(
                    size: 13,
                    weight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const Spacer(),
                if (locked)
                  const Icon(
                    CupertinoIcons.lock_fill,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                if (!canSee && analysisLevel == 'group_totals')
                  Text(
                    'Totals only',
                    style: _cairo(size: 10, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          children: [
            for (final acc in accounts) ...[
              const Divider(height: 1, color: AppColors.borderLight),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                // Amount left · name right (Arabic-friendly).
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.money(
                        (acc['amount'] as num?)?.toDouble() ?? 0,
                      ),
                      style: _cairo(
                        size: 13,
                        weight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${acc['name'] ?? ''}'.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: _cairo(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
