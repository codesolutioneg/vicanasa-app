import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bilingual_display.dart';
import '../../domain/closed_month_option.dart';

/// Bottom sheet to pick one or more closed months only.
Future<List<ClosedMonthOption>?> showClosedMonthsPickerSheet({
  required BuildContext context,
  required List<ClosedMonthOption> closedMonths,
  required List<String> initialSelectedKeys,
}) {
  return showModalBottomSheet<List<ClosedMonthOption>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _ClosedMonthsPickerBody(
      closedMonths: closedMonths,
      initialSelectedKeys: initialSelectedKeys,
    ),
  );
}

class _ClosedMonthsPickerBody extends StatefulWidget {
  const _ClosedMonthsPickerBody({
    required this.closedMonths,
    required this.initialSelectedKeys,
  });

  final List<ClosedMonthOption> closedMonths;
  final List<String> initialSelectedKeys;

  @override
  State<_ClosedMonthsPickerBody> createState() => _ClosedMonthsPickerBodyState();
}

class _ClosedMonthsPickerBodyState extends State<_ClosedMonthsPickerBody> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialSelectedKeys);
    if (_selected.isEmpty && widget.closedMonths.isNotEmpty) {
      _selected.add(widget.closedMonths.first.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select closed months / اختر الشهور المغلقة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Only closed periods are available. Unclosed months cannot be selected.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.closedMonths.length,
              itemBuilder: (context, index) {
                final m = widget.closedMonths[index];
                return CheckboxListTile(
                  value: _selected.contains(m.key),
                  title: BilingualDisplay.monthLabel(
                    m.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                  dense: true,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selected.add(m.key);
                      } else {
                        _selected.remove(m.key);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _selected.isEmpty
                ? null
                : () {
                    final picked = widget.closedMonths
                        .where((m) => _selected.contains(m.key))
                        .toList();
                    Navigator.pop(context, picked);
                  },
            child: const Text('Apply / تطبيق'),
          ),
        ],
      ),
    );
  }
}
