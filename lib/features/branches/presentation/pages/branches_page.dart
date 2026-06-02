import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    final filter = context.read<FilterCubit>().state;
    final result = await sl<FinancialRepository>().getBranches(
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
        final branches = _data!['branch_performance'] as List? ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (branches.isEmpty) Center(child: Text(l10n.noData)),
            ...branches.map((b) {
              final m = Map<String, dynamic>.from(b as Map);
              return Card(
                child: ListTile(
                  title: Text('${m['name']}'),
                  subtitle: Text('${m['share_percentage']}%'),
                  trailing: Text(NumberFormat('#,##0.00').format(_n(m['net_profit']))),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
