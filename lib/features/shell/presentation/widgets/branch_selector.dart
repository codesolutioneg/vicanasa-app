import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/filter_cubit.dart';

class BranchSelector extends StatelessWidget {
  const BranchSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthCubit>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final options = auth.partner.analyticOptions;
    final filter = context.watch<FilterCubit>().state;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<int?>(
        value: filter.analyticId,
        decoration: InputDecoration(
          labelText: l10n.allBranches,
          isDense: true,
        ),
        items: [
          DropdownMenuItem<int?>(value: null, child: Text(l10n.allBranches)),
          ...options.map((o) => DropdownMenuItem(
                value: o.id,
                child: Text(o.name),
              )),
        ],
        onChanged: (v) => context.read<FilterCubit>().setBranch(v),
      ),
    );
  }
}
