// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Vicanza';

  @override
  String get splashLoading => 'جاري التحميل…';

  @override
  String get onboardingTitle1 => 'لوحة التحكم المالية';

  @override
  String get onboardingDesc1 =>
      'تابع الإيرادات والتكاليف وحصتك كشريك في الوقت الفعلي.';

  @override
  String get onboardingTitle2 => 'رؤى الفروع';

  @override
  String get onboardingDesc2 => 'قارن الفروع والتوزيعات وأرصدة رأس المال.';

  @override
  String get onboardingTitle3 => 'ابق على اطلاع';

  @override
  String get onboardingDesc3 => 'استلم إشعارات عند تحديث التقارير والفترات.';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'دخول البوابة للشركاء الماليين';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل كلمة مرور جديدة إلى صندوق الوارد.';

  @override
  String get forgotPasswordHint => 'أدخل بريدك الإلكتروني';

  @override
  String get forgotPasswordButton => 'إرسال كلمة مرور جديدة';

  @override
  String get sendingEmailTitle => 'جاري إرسال الإيميل…';

  @override
  String get sendingEmailSubtitle =>
      'يرجى الانتظار بينما نرسل كلمة مرور جديدة إلى بريدك.';

  @override
  String get resetPasswordSentTitle => 'تحقق من بريدك';

  @override
  String resetPasswordSentMessage(String email) {
    return 'تم إرسال كلمة مرور جديدة إلى $email. استخدمها لتسجيل الدخول.';
  }

  @override
  String get resetPasswordSentHint =>
      'قد يصل خلال دقائق إذا كان سيرفر البريد مشغولاً. تحقق أيضاً من البريد غير المرغوب فيه.';

  @override
  String get resetPasswordBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get loginError => 'بيانات غير صحيحة أو الوصول مرفوض';

  @override
  String get accessDeniedTitle => 'الوصول مرفوض';

  @override
  String get accessDeniedMessage => 'حسابك غير مفعّل كشريك مالي.';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get demoWelcome => 'تطبيق تجريبي';

  @override
  String get demoSubtitle => 'تجربة مالية تجريبية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navPnl => 'الأرباح والخسائر';

  @override
  String get navComparison => 'المقارنة';

  @override
  String get navReports => 'التقارير';

  @override
  String get navMore => 'المزيد';

  @override
  String get navGrowth => 'النمو';

  @override
  String get navBranches => 'الفروع';

  @override
  String get navDistributions => 'التوزيعات';

  @override
  String get navCapital => 'رأس المال';

  @override
  String get allBranches => 'جميع الفروع';

  @override
  String get dateFrom => 'من';

  @override
  String get dateTo => 'إلى';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetMessage =>
      'يرجى التحقق من شبكة الواي فاي أو بيانات الجوال والمحاولة مرة أخرى.';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String monthClosingWarning(String period) {
    return 'البيانات متاحة حتى $period';
  }

  @override
  String get kpiRevenue => 'الإيرادات';

  @override
  String get kpiCost => 'التكلفة';

  @override
  String get kpiExpense => 'المصروفات';

  @override
  String get kpiGrossProfit => 'إجمالي الربح';

  @override
  String get kpiNetProfit => 'صافي الربح';

  @override
  String get kpiPartnerShare => 'حصتك';

  @override
  String get filterMtd => 'الشهر';

  @override
  String get filterYtd => 'السنة';

  @override
  String get filterLastMonth => 'الشهر السابق';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get reportsExportPdf => 'تصدير PDF';

  @override
  String get reportsExportHint =>
      'إنشاء ملخص مالي للفترة والفروع المحددة، ثم المعاينة أو الطباعة أو المشاركة.';

  @override
  String get pdfGeneratedTitle => 'التقرير جاهز';

  @override
  String get pdfChooseShare => 'اختر طريقة المشاركة';

  @override
  String get pdfPreviewPrint => 'معاينة / طباعة';

  @override
  String get pdfShare => 'مشاركة';

  @override
  String get pdfSave => 'حفظ';

  @override
  String get pdfReady => 'جاهز';

  @override
  String get filterApply => 'تطبيق';

  @override
  String get navSectionMain => 'الرئيسية';

  @override
  String get navSectionMore => 'المزيد';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get accountDetails => 'تفاصيل الحساب';

  @override
  String get transactions => 'المعاملات';

  @override
  String get year => 'السنة';

  @override
  String get selectYears => 'اختر السنوات';

  @override
  String get total => 'الإجمالي';

  @override
  String get sharePercent => 'نسبة الحصة';

  @override
  String get noData => 'لا توجد بيانات';
}
