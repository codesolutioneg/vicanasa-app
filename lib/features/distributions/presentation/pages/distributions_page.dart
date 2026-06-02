import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class DistributionsPage extends StatefulWidget {
  const DistributionsPage({super.key});

  @override
  State<DistributionsPage> createState() => _DistributionsPageState();
}

class _DistributionsPageState extends State<DistributionsPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  int _year = DateTime.now().year;

  Future<void> _load() async {
    setState(() => _loading = true);
    final filter = context.read<FilterCubit>().state;
    final result = await sl<FinancialRepository>().getDistributions(
      year: _year,
      analyticId: filter.analyticId,
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (d) => setState(() {
        _data = d;
        _year = d['current_year'] as int? ?? _year;
        _error = null;
        _loading = false;
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<FilterCubit, FilterState>(
      listener: (_, __) => _load(),
      child: Builder(builder: (context) {
        if (_loading) return const Center(child: CircularProgressIndicator());
        if (_error != null) return ErrorRetry(message: _error!, onRetry: _load);
        final quarterly = _data!['quarterly_data'] as List? ?? [];
        final byBranch = _data!['distribution_by_branch'] as List? ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${l10n.year}: $_year', style: Theme.of(context).textTheme.titleMedium),
            Text('Annual share: ${NumberFormat('#,##0.00').format(_n(_data!['total_annual_share']))}'),
            const Divider(),
            Text('Quarterly', style: Theme.of(context).textTheme.titleSmall),
            ...quarterly.map((q) {
              final m = Map<String, dynamic>.from(q as Map);
              return ListTile(
                title: Text('Q${m['quarter']}'),
                trailing: Text(NumberFormat('#,##0.00').format(_n(m['share']))),
              );
            }),
            const Divider(),
            Text('By Branch', style: Theme.of(context).textTheme.titleSmall),
            ...byBranch.map((b) {
              final m = Map<String, dynamic>.from(b as Map);
              return ListTile(
                title: Text('${m['name']}'),
                trailing: Text(NumberFormat('#,##0.00').format(_n(m['share']))),
              );
            }),
          ],
        );
      }),
    );
  }
}
