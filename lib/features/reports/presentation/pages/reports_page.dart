import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../data/financial_pdf_builder.dart';
import '../../data/pdf_export_service.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _busy = false;

  Future<void> _exportFinancialPdf() async {
    setState(() => _busy = true);
    final filter = context.read<FilterCubit>().state;
    final auth = context.read<AuthCubit>().state;
    final name = auth is AuthAuthenticated
        ? auth.partner.partnerName ?? 'Partner'
        : 'Partner';

    final dataResult = await sl<FinancialRepository>().getFinancialData(
      dateFrom: filter.dateFromStr,
      dateTo: filter.dateToStr,
      analyticId: filter.analyticId,
    );
    final partner = auth is AuthAuthenticated ? auth.partner : null;
    await dataResult.fold(
      (f) async {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message)));
        }
      },
      (data) async {
        final branchData = <Map<String, dynamic>>[];
        if (partner != null) {
          for (final opt in partner.analyticOptions) {
            final br = await sl<FinancialRepository>().getFinancialData(
              dateFrom: filter.dateFromStr,
              dateTo: filter.dateToStr,
              analyticId: opt.id,
            );
            br.fold((_) {}, (d) {
              branchData.add({
                'name': opt.name,
                'share_percentage': opt.sharePercentage,
                'data': d,
              });
            });
          }
        }
        final bytes = await sl<FinancialPdfBuilder>().build(
          partnerName: name,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          financialData: data,
          branchData: branchData,
        );
        if (mounted) {
          await sl<PdfExportService>().shareFinancialReport(
            bytes: bytes,
            partnerName: name,
            context: context,
          );
        }
      },
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_text_fill,
                      color: AppColors.primaryMid,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.reportsTitle, style: AppTextStyles.headlineSm),
                        const SizedBox(height: 4),
                        Text(
                          l10n.reportsExportHint,
                          style: AppTextStyles.bodyMd,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceLg),
              FilledButton.icon(
                onPressed: _busy ? null : _exportFinancialPdf,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(CupertinoIcons.arrow_down_doc_fill),
                label: Text(l10n.reportsExportPdf),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
