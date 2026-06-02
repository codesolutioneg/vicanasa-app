import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class CapitalPage extends StatefulWidget {
  const CapitalPage({super.key});

  @override
  State<CapitalPage> createState() => _CapitalPageState();
}

class _CapitalPageState extends State<CapitalPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    final filter = context.read<FilterCubit>().state;
    final result = await sl<FinancialRepository>().getCapital(
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
        final branches = _data!['branch_capital_data'] as List? ?? [];
        return ListView(
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(l10n.total),
              trailing: Text(NumberFormat('#,##0.00').format(_n(_data!['remaining_balance']))),
            ),
            ...branches.map((b) {
              final m = Map<String, dynamic>.from(b as Map);
              return ExpansionTile(
                title: Text('${m['name']}'),
                children: [
                  ListTile(title: const Text('Capital'), trailing: Text(_fmt(m['capital']))),
                  ListTile(title: const Text('Distributions'), trailing: Text(_fmt(m['distributions']))),
                  ListTile(title: const Text('Remaining'), trailing: Text(_fmt(m['remaining_balance']))),
                ],
              );
            }),
          ],
        );
      }),
    );
  }

  String _fmt(dynamic v) => NumberFormat('#,##0.00').format(_n(v));
}
