import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/onboarding_repository.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _page = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = [
      (l10n.onboardingTitle1, l10n.onboardingDesc1, CupertinoIcons.chart_bar_square_fill),
      (l10n.onboardingTitle2, l10n.onboardingDesc2, CupertinoIcons.building_2_fill),
      (l10n.onboardingTitle3, l10n.onboardingDesc3, CupertinoIcons.bell_fill),
    ];
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    l10n.onboardingSkip,
                    style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: slides.length,
                  itemBuilder: (_, i) {
                    final s = slides[i];
                    return Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceXl),
                      child: LiquidGlassModal(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(s.$3, size: 72, color: AppColors.primaryMid),
                            const SizedBox(height: AppDimensions.spaceLg),
                            Text(s.$1, textAlign: TextAlign.center, style: AppTextStyles.headlineMd),
                            const SizedBox(height: 12),
                            Text(s.$2, textAlign: TextAlign.center, style: AppTextStyles.bodyMd),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: FilledButton(
                  onPressed: _index < slides.length - 1
                      ? () => _page.nextPage(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeInOutCubicEmphasized,
                          )
                      : _finish,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.bgSecondary,
                    foregroundColor: AppColors.primaryMid,
                  ),
                  child: Text(
                    _index < slides.length - 1
                        ? l10n.onboardingNext
                        : l10n.onboardingGetStarted,
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await sl<OnboardingRepository>().complete();
    if (mounted) context.go(AppRoutes.login);
  }
}
