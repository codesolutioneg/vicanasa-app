/// Permission rules matching Odoo portal revenue/deductions modals.
bool canSeeGroupDetails({
  required String analysisLevel,
  required List<int> allowedGroupIds,
  required int? groupId,
}) {
  if (analysisLevel == 'all_details') return true;
  if (analysisLevel == 'custom' && groupId != null) {
    return allowedGroupIds.contains(groupId);
  }
  return false;
}

bool showGroupLockIcon({
  required String analysisLevel,
  required bool canSeeDetails,
}) {
  return !canSeeDetails && analysisLevel != 'group_totals';
}
