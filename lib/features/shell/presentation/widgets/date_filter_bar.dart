import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/filter_cubit.dart';

class DateFilterBar extends StatefulWidget {
  const DateFilterBar({super.key});

  @override
  State<DateFilterBar> createState() => _DateFilterBarState();
}

class _DateFilterBarState extends State<DateFilterBar> {
  late DateTime _draftFrom;
  late DateTime _draftTo;

  @override
  void initState() {
    super.initState();
    final f = context.read<FilterCubit>().state;
    _draftFrom = f.dateFrom;
    _draftTo = f.dateTo;
  }

  Future<void> _pickDate(bool isFrom) async {
    final filter = context.read<FilterCubit>().state;
    final lastDate = filter.maxSelectableDate;
    var initial = isFrom ? _draftFrom : _draftTo;
    if (initial.isAfter(lastDate)) initial = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );
    if (picked == null) return;
    if (!filter.isMonthSelectable(picked.year, picked.month)) return;
    setState(() {
      if (isFrom) {
        _draftFrom = picked;
        if (_draftTo.isBefore(_draftFrom)) _draftTo = _draftFrom;
      } else {
        _draftTo = picked;
        if (_draftFrom.isAfter(_draftTo)) _draftFrom = _draftTo;
      }
      if (_draftTo.isAfter(lastDate)) _draftTo = lastDate;
      if (_draftFrom.isAfter(lastDate)) _draftFrom = lastDate;
    });
  }

  void _apply() {
    context.read<FilterCubit>().setDateRange(_draftFrom, _draftTo);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = context.watch<FilterCubit>().state;
    final fmt = DateFormat.yMMMd();
    final inputFmt = DateFormat('MM/dd/yyyy');

    return BlocListener<FilterCubit, FilterState>(
      listenWhen: (a, b) => a.dateFrom != b.dateFrom || a.dateTo != b.dateTo,
      listener: (_, state) {
        setState(() {
          _draftFrom = state.dateFrom;
          _draftTo = state.dateTo;
        });
      },
      child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: Text(l10n.filterMtd),
                selected: false,
                onSelected: (_) => context.read<FilterCubit>().setMtd(),
              ),
              FilterChip(
                label: Text(l10n.filterYtd),
                selected: false,
                onSelected: (_) => context.read<FilterCubit>().setYtd(),
              ),
              FilterChip(
                label: Text(l10n.filterLastMonth),
                selected: false,
                onSelected: (_) => context.read<FilterCubit>().setLastMonth(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'FROM',
                  value: inputFmt.format(_draftFrom),
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateField(
                  label: 'TO',
                  value: inputFmt.format(_draftTo),
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _apply,
              child: Text(l10n.filterApply),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${fmt.format(filter.dateFrom)} → ${fmt.format(filter.dateTo)}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: const Icon(CupertinoIcons.calendar, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(value, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
