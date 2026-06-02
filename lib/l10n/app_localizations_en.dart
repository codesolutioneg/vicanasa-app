// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vicanza';

  @override
  String get splashLoading => 'Loading…';

  @override
  String get onboardingTitle1 => 'Your Financial Dashboard';

  @override
  String get onboardingDesc1 =>
      'Track revenue, costs, and your partner share in real time.';

  @override
  String get onboardingTitle2 => 'Branch Insights';

  @override
  String get onboardingDesc2 =>
      'Compare branches, distributions, and capital balances.';

  @override
  String get onboardingTitle3 => 'Stay Informed';

  @override
  String get onboardingDesc3 =>
      'Receive notifications when reports and periods are updated.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Portal access for financial partners';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginError => 'Invalid credentials or access denied';

  @override
  String get accessDeniedTitle => 'Access Denied';

  @override
  String get accessDeniedMessage =>
      'Your account is not enabled as a financial partner.';

  @override
  String get logout => 'Log out';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navPnl => 'P&L';

  @override
  String get navComparison => 'Comparison';

  @override
  String get navReports => 'Reports';

  @override
  String get navMore => 'More';

  @override
  String get navGrowth => 'Growth';

  @override
  String get navBranches => 'Branches';

  @override
  String get navDistributions => 'Distributions';

  @override
  String get navCapital => 'Capital';

  @override
  String get allBranches => 'All Branches';

  @override
  String get dateFrom => 'From';

  @override
  String get dateTo => 'To';

  @override
  String get retry => 'Retry';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get noInternetTitle => 'No Internet Connection';

  @override
  String get noInternetMessage =>
      'Please check your Wi‑Fi or mobile data and try again.';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String monthClosingWarning(String period) {
    return 'Data is available until $period';
  }

  @override
  String get kpiRevenue => 'Revenue';

  @override
  String get kpiCost => 'Cost';

  @override
  String get kpiExpense => 'Expense';

  @override
  String get kpiGrossProfit => 'Gross Profit';

  @override
  String get kpiNetProfit => 'Net Profit';

  @override
  String get kpiPartnerShare => 'Your Share';

  @override
  String get filterMtd => 'MTD';

  @override
  String get filterYtd => 'YTD';

  @override
  String get filterLastMonth => 'Last Month';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsExportPdf => 'Export PDF';

  @override
  String get reportsExportHint =>
      'Build a financial summary for the selected period and branches, then preview, print, or share.';

  @override
  String get pdfGeneratedTitle => 'Report ready';

  @override
  String get pdfChooseShare => 'Choose how to share';

  @override
  String get pdfPreviewPrint => 'Preview / Print';

  @override
  String get pdfShare => 'Share';

  @override
  String get pdfSave => 'Save';

  @override
  String get pdfReady => 'Ready';

  @override
  String get filterApply => 'Apply';

  @override
  String get navSectionMain => 'Main';

  @override
  String get navSectionMore => 'More';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get transactions => 'Transactions';

  @override
  String get year => 'Year';

  @override
  String get selectYears => 'Select years';

  @override
  String get total => 'Total';

  @override
  String get sharePercent => 'Share %';

  @override
  String get noData => 'No data available';
}
