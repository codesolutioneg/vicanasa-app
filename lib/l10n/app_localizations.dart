import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vicanza'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splashLoading;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Financial Dashboard'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Track revenue, costs, and your partner share in real time.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Branch Insights'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Compare branches, distributions, and capital balances.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay Informed'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when reports and periods are updated.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Portal access for financial partners'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a new password to your inbox.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get forgotPasswordHint;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send new password'**
  String get forgotPasswordButton;

  /// No description provided for @sendingEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sending email…'**
  String get sendingEmailTitle;

  /// No description provided for @sendingEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we send a new password to your inbox.'**
  String get sendingEmailSubtitle;

  /// No description provided for @resetPasswordSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get resetPasswordSentTitle;

  /// No description provided for @resetPasswordSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A new password was sent to {email}. Use it to sign in.'**
  String resetPasswordSentMessage(String email);

  /// No description provided for @resetPasswordSentHint.
  ///
  /// In en, this message translates to:
  /// **'It may take a few minutes if the mail server is busy. Check spam too.'**
  String get resetPasswordSentHint;

  /// No description provided for @resetPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get resetPasswordBackToLogin;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials or access denied'**
  String get loginError;

  /// No description provided for @accessDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDeniedTitle;

  /// No description provided for @accessDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is not enabled as a financial partner.'**
  String get accessDeniedMessage;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @demoWelcome.
  ///
  /// In en, this message translates to:
  /// **'Demo App'**
  String get demoWelcome;

  /// No description provided for @demoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sample financial experience'**
  String get demoSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navPnl.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get navPnl;

  /// No description provided for @navComparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get navComparison;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get navGrowth;

  /// No description provided for @navBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get navBranches;

  /// No description provided for @navDistributions.
  ///
  /// In en, this message translates to:
  /// **'Distributions'**
  String get navDistributions;

  /// No description provided for @navCapital.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get navCapital;

  /// No description provided for @allBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get allBranches;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get dateTo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your Wi‑Fi or mobile data and try again.'**
  String get noInternetMessage;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @monthClosingWarning.
  ///
  /// In en, this message translates to:
  /// **'Data is available until {period}'**
  String monthClosingWarning(String period);

  /// No description provided for @kpiRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get kpiRevenue;

  /// No description provided for @kpiCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get kpiCost;

  /// No description provided for @kpiExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get kpiExpense;

  /// No description provided for @kpiGrossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get kpiGrossProfit;

  /// No description provided for @kpiNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get kpiNetProfit;

  /// No description provided for @kpiPartnerShare.
  ///
  /// In en, this message translates to:
  /// **'Your Share'**
  String get kpiPartnerShare;

  /// No description provided for @filterMtd.
  ///
  /// In en, this message translates to:
  /// **'MTD'**
  String get filterMtd;

  /// No description provided for @filterYtd.
  ///
  /// In en, this message translates to:
  /// **'YTD'**
  String get filterYtd;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get filterLastMonth;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get reportsExportPdf;

  /// No description provided for @reportsExportHint.
  ///
  /// In en, this message translates to:
  /// **'Build a financial summary for the selected period and branches, then preview, print, or share.'**
  String get reportsExportHint;

  /// No description provided for @pdfGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'Report ready'**
  String get pdfGeneratedTitle;

  /// No description provided for @pdfChooseShare.
  ///
  /// In en, this message translates to:
  /// **'Choose how to share'**
  String get pdfChooseShare;

  /// No description provided for @pdfPreviewPrint.
  ///
  /// In en, this message translates to:
  /// **'Preview / Print'**
  String get pdfPreviewPrint;

  /// No description provided for @pdfShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pdfShare;

  /// No description provided for @pdfSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pdfSave;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get pdfReady;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApply;

  /// No description provided for @navSectionMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get navSectionMain;

  /// No description provided for @navSectionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navSectionMore;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @selectYears.
  ///
  /// In en, this message translates to:
  /// **'Select years'**
  String get selectYears;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @sharePercent.
  ///
  /// In en, this message translates to:
  /// **'Share %'**
  String get sharePercent;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
