// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'موظفو وافلو';

  @override
  String get bootProgress => 'جارٍ التحقق من هذا الجهاز بأمان';

  @override
  String get welcomeTitle => 'إقران جهاز الموظف';

  @override
  String get welcomeBody =>
      'اطلب من المالك أو المدير إنشاء رمز إقران لمرة واحدة من لوحة تحكم وافلو.';

  @override
  String get scanPairingCode => 'مسح رمز الإقران';

  @override
  String get securitySummary =>
      'لن تُدخل كلمة مرور لوحة التحكم هنا. ينشئ هذا الجهاز مفتاح الحماية الخاص به ويحميه.';

  @override
  String get chooseLanguage => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get cameraTitle => 'استخدام الكاميرا للإقران';

  @override
  String get cameraBody =>
      'تستخدم وافلو للموظفين الكاميرا فقط لمسح رمز إقران جهاز الموظف لمرة واحدة.';

  @override
  String get continueAction => 'متابعة';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get cameraDenied =>
      'الوصول إلى الكاميرا متوقف. يمكنك إدخال رمز الإقران بأمان بدلاً من ذلك.';

  @override
  String get scannerTitle => 'مسح رمز إقران الموظف';

  @override
  String get scannerInstructions =>
      'ضع رمز إقران الموظف لمرة واحدة داخل الإطار.';

  @override
  String get toggleFlash => 'تشغيل أو إيقاف ضوء الكاميرا';

  @override
  String get close => 'إغلاق';

  @override
  String get enterCodeInstead => 'إدخال الرمز بدلاً من ذلك';

  @override
  String get manualCodeTitle => 'إدخال رمز الإقران';

  @override
  String get manualCodeHint => 'رمز الإقران لمرة واحدة';

  @override
  String get submitCode => 'متابعة بأمان';

  @override
  String get invalidPairing => 'هذا ليس رمز إقران صالحاً لموظفي وافلو.';

  @override
  String get expiredPairing => 'انتهت صلاحية رمز الإقران. اطلب رمزاً جديداً.';

  @override
  String get usedPairing => 'استُخدم رمز الإقران مسبقاً. اطلب رمزاً جديداً.';

  @override
  String get wrongEnvironmentPairing =>
      'رمز الإقران هذا تابع لبيئة وافلو أخرى.';

  @override
  String get pairingProgressTitle => 'جارٍ تأمين الجهاز';

  @override
  String get pairingValidating => 'جارٍ التحقق من رمز الإقران';

  @override
  String get pairingCreatingIdentity => 'جارٍ إنشاء مفتاح حماية الجهاز';

  @override
  String get pairingClaiming => 'جارٍ حجز جلسة الإقران';

  @override
  String get pairingSigning => 'جارٍ توقيع تحدي الحماية';

  @override
  String get pairingCompleting => 'جارٍ إكمال إقران الجهاز';

  @override
  String get pairingSaving => 'جارٍ حفظ الجلسة الآمنة';

  @override
  String get pairingLoadingContext => 'جارٍ تحميل سياق الجهاز المعيّن';

  @override
  String get pairingSuccessTitle => 'تم إقران الجهاز';

  @override
  String get pairingSuccessBody =>
      'الجهاز جاهز للاستخدام المصرح به من موظفي وافلو.';

  @override
  String get goHome => 'المتابعة إلى الرئيسية';

  @override
  String get deviceReady => 'الجهاز جاهز';

  @override
  String get verifiedByWaflo => 'تم التحقق بواسطة وافلو';

  @override
  String get roleLabel => 'الدور';

  @override
  String get roleOwner => 'المالك';

  @override
  String get roleManager => 'المدير';

  @override
  String get roleStaff => 'الموظف';

  @override
  String get platformLabel => 'المنصة';

  @override
  String get platformIos => 'iOS';

  @override
  String get platformAndroid => 'Android';

  @override
  String assignedLocations(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موقع معيّن',
      many: '$count موقعاً معيّناً',
      few: '$count مواقع معيّنة',
      two: 'موقعان معيّنان',
      one: 'موقع معيّن واحد',
      zero: 'لا توجد مواقع معيّنة',
    );
    return '$_temp0';
  }

  @override
  String get securityStatus => 'حالة الحماية';

  @override
  String get active => 'نشط';

  @override
  String lastSynchronized(Object time) {
    return 'آخر مزامنة $time';
  }

  @override
  String get home => 'الرئيسية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get scanCustomer => 'مسح العميل';

  @override
  String get recentOperations => 'العمليات الأخيرة';

  @override
  String get managerApprovals => 'موافقات المدير';

  @override
  String get availableInNextPhase => 'غير متاح في M1';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'مظهر النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get deviceInformation => 'معلومات الجهاز';

  @override
  String appVersion(Object version) {
    return 'إصدار التطبيق $version';
  }

  @override
  String environment(Object environment) {
    return 'البيئة: $environment';
  }

  @override
  String get refreshContext => 'تحديث سياق الجهاز';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutTitle => 'تسجيل الخروج من هذا الجهاز؟';

  @override
  String get signOutBody =>
      'ستُحذف جلسة الخادم ومفتاح الحماية المحلي، وستحتاج إلى رمز إقران جديد من لوحة التحكم.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get support => 'الدعم';

  @override
  String get openSourceLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get offlineBanner =>
      'لا يمكن الوصول إلى وافلو. لا تسمح المعلومات المحفوظة بتنفيذ أي عمليات.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get sessionExpiredTitle => 'انتهت صلاحية الجلسة';

  @override
  String get sessionExpiredBody =>
      'يحتاج هذا الجهاز إلى رمز إقران جديد قبل المتابعة.';

  @override
  String get deviceRevokedTitle => 'تم إلغاء الجهاز';

  @override
  String get deviceRevokedBody =>
      'لم يعد هذا الجهاز مصرحاً به. تواصل مع المالك أو المدير.';

  @override
  String get deviceCompromisedTitle => 'تم حظر الجهاز للحماية';

  @override
  String get deviceCompromisedBody =>
      'حظرت وافلو هذا الجهاز لحماية حساب التاجر.';

  @override
  String get updateRequiredTitle => 'التحديث مطلوب';

  @override
  String get updateRequiredBody =>
      'ثبّت أحدث إصدار من وافلو للموظفين للمتابعة بأمان.';

  @override
  String get backendUnavailableTitle => 'وافلو غير متاحة';

  @override
  String get backendUnavailableBody =>
      'تحقق من الاتصال ثم حاول مجدداً. لم يُصنّف جهازك على أنه ملغى.';

  @override
  String get configurationErrorTitle => 'خطأ في إعداد التطبيق';

  @override
  String get configurationErrorBody =>
      'لا يستطيع هذا الإصدار الاتصال بأمان. تواصل مع دعم وافلو.';

  @override
  String get localSecurityErrorTitle => 'مفتاح الحماية المحلي غير متاح';

  @override
  String get localSecurityErrorBody =>
      'مفتاح الجهاز المقترن مفقود أو تالف. يلزم إعادة ضبط مقصودة وإقران جديد.';

  @override
  String get resetForRepair => 'إعادة الضبط لإقران جديد';

  @override
  String get genericError => 'حدث خطأ. حاول مرة أخرى بأمان.';

  @override
  String get validationError => 'تحقق من معلومات الإقران المرسلة.';

  @override
  String get signatureError => 'تعذر التحقق من طلب الجهاز الآمن.';

  @override
  String get clockSkewError => 'فعّل التاريخ والوقت التلقائيين ثم حاول مجدداً.';

  @override
  String get nonceReplayError =>
      'استُخدم الطلب مسبقاً. يلزم إنشاء طلب آمن جديد.';

  @override
  String get assignmentRequiredError => 'يلزم تعيين موظف نشط لهذا الجهاز.';

  @override
  String get locationNotAuthorizedError =>
      'هذا الجهاز غير مصرح له بهذا الموقع.';

  @override
  String get riskBlockedError => 'حظرت وافلو هذا الطلب لمراجعة الحماية.';

  @override
  String requestReference(Object requestId) {
    return 'مرجع الطلب: $requestId';
  }
}
