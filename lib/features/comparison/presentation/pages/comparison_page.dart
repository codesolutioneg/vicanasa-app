import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/shimmer/shimmer.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';
import '../../data/comparison_loader.dart';
import '../comparison_selection.dart';
import '../comparison_session.dart';
import '../widgets/comparison_body.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late final ComparisonSession _session =
      ComparisonSession(ComparisonLoader(sl()));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    _session.bootstrap(context.read<FilterCubit>().state);
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _session.loading = true);
    await _session.load(context.read<FilterCubit>().state);
    if (mounted) setState(() {});
  }

  Future<void> _run(void Function() mutate) async {
    setState(mutate);
    await _reload();
  }

  Future<void> _addCustom() async {
    final year = _session.scopeYear;
    if (year == null) return;
    final filter = context.read<FilterCubit>().state;
    final first = DateTime(year, 1, 1);
    var last = DateTime(year, 12, 31);
    final max = filter.maxSelectableDate;
    if (last.isAfter(max)) last = max;
    if (first.isAfter(last)) return;

    final range = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      currentDate: first,
      helpText: 'Select period in $year',
    );
    if (range == null || !mounted) return;
    await _run(() => _session.addCustom(range));
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterCubit>().state;
    if (_session.consumeBranchChange(filter.analyticId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    }

    if (_session.loading && _session.cards.isEmpty) {
      return const ComparisonPageShimmer();
    }

    final scope = _session.scopeYear;
    final months = scope == null
        ? const <Never>[]
        : ComparisonSelection.monthsForYear(filter, scope);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      child: ComparisonBody(
        mode: _session.mode,
        availableYears: _session.availableYears,
        selectedYears: _session.selectedYears,
        scopeYear: scope,
        selectedMonthKeys: _session.selectedMonthKeys,
        customPeriods: _session.customPeriods,
        cards: _session.cards,
        loading: _session.loading,
        error: _session.error,
        validationError: _session.validationError,
        months: List.from(months),
        onRetry: _reload,
        onRefresh: _reload,
        onModeChanged: (m) => _run(() => _session.setMode(m)),
        onToggleYear: (y) => _run(() => _session.toggleYear(y)),
        onScopeYear: (y) => setState(() => _session.setScopeYear(y)),
        onToggleMonth: (m) => _run(() => _session.toggleMonth(m)),
        onAddCustom: _addCustom,
        onRemoveCustom: (id) => _run(() => _session.removeCustom(id)),
      ),
    );
  }
}
