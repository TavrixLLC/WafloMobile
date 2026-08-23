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
  String get kurdishGroup => 'کوردی';

  @override
  String get kurdishBadini => 'بادینی';

  @override
  String get kurdishSorani => 'سۆرانی';

  @override
  String get cameraTitle => 'استخدام الكاميرا للإقران';

  @override
  String get cameraBody =>
      'يستخدم تطبيق وافلو للموظفين الكاميرا لمسح رموز إقران الموظفين ورموز عضوية العملاء.';

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
  String get pairingRecovering => 'جارٍ استعادة تحدي الإقران الآمن';

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
  String get organizationLabel => 'المؤسسة';

  @override
  String get staffLabel => 'الموظف';

  @override
  String get deviceStatusLabel => 'حالة الجهاز';

  @override
  String get currentLocationLabel => 'الموقع الحالي';

  @override
  String get locationsTitle => 'المواقع المعيّنة';

  @override
  String get earningCapability => 'الاكتساب';

  @override
  String get redemptionCapability => 'الاستبدال';

  @override
  String get capabilityAllowed => 'مسموح';

  @override
  String get capabilityBlocked => 'غير مسموح';

  @override
  String get updatePolicyLabel => 'سياسة التحديث';

  @override
  String minimumSupportedVersion(Object version) {
    return 'الحد الأدنى للإصدار المدعوم: $version';
  }

  @override
  String get appVersionCurrent => 'إصدار التطبيق هذا مدعوم';

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
  String get homeHeaderTitle => 'كل زيارة تحسب';

  @override
  String get homeHeaderSubtitle => 'امسح العميل وخلّي وافلو يتابع الباقي.';

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
  String get staffUserDeactivatedTitle => 'تم إيقاف وصول الموظف';

  @override
  String get staffUserDeactivatedBody =>
      'هوية هذا الموظف غير نشطة. اطلب من المالك إعادة تفعيلها ثم أعد إقران الهاتف.';

  @override
  String get staffMembershipInactiveTitle => 'عضوية الموظف غير نشطة';

  @override
  String get staffMembershipInactiveBody =>
      'لم يعد الوصول إلى هذا التاجر نشطاً. تواصل مع المالك أو المدير ثم أعد إقران الهاتف.';

  @override
  String get staffLocationInvalidTitle => 'تمت إزالة صلاحية الموقع';

  @override
  String get staffLocationInvalidBody =>
      'لم يعد هذا الهاتف مخصصاً للموقع المقترن به. اطلب من المالك أو المدير تعيينه وإقرانه من جديد.';

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
  String get pairDeviceAgain => 'إقران الجهاز مرة أخرى';

  @override
  String get genericError => 'حدث خطأ. حاول مرة أخرى بأمان.';

  @override
  String get operationNotCompleted => 'لم تكتمل العملية';

  @override
  String get customerOperationsPaused => 'عمليات العملاء متوقفة مؤقتاً';

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

  @override
  String get m2ScannerTitle => 'مسح العميل';

  @override
  String get m2ScannerInstructions =>
      'ضع رمز عضوية وافلو للعميل داخل الإطار. لن يُعرض الرمز أو يُحفظ.';

  @override
  String get resolvingMembership => 'جارٍ التحقق من العضوية بأمان';

  @override
  String get membershipTitle => 'العضوية';

  @override
  String get customerLabel => 'العميل';

  @override
  String get programLabel => 'البرنامج';

  @override
  String get membershipStatusLabel => 'حالة العضوية';

  @override
  String get membershipStatusActive => 'نشطة';

  @override
  String get membershipStatusSuspended => 'معلّقة';

  @override
  String get membershipStatusExpired => 'منتهية';

  @override
  String get membershipStatusRevoked => 'ملغاة';

  @override
  String progressOf(Object goal, Object progress) {
    return '$progress من $goal طوابع';
  }

  @override
  String completedCycles(Object count) {
    return 'الدورات المكتملة: $count';
  }

  @override
  String resolvedAt(Object time) {
    return 'تم التحقق $time';
  }

  @override
  String get rewardReady => 'المكافأة النهائية جاهزة';

  @override
  String get earningAvailable => 'إضافة الطوابع متاحة هنا';

  @override
  String get redemptionAvailable => 'استرداد المكافآت متاح هنا';

  @override
  String get stampAmount => 'عدد الطوابع';

  @override
  String projectedProgress(Object goal, Object progress) {
    return 'بعد الموافقة: $progress من $goal';
  }

  @override
  String get purchaseAmount => 'مبلغ الشراء';

  @override
  String requiredCurrency(Object currency) {
    return 'العملة المطلوبة: $currency';
  }

  @override
  String purchaseMinimum(Object amount) {
    return 'الحد الأدنى للشراء: $amount';
  }

  @override
  String get transactionReference => 'مرجع المعاملة';

  @override
  String get optionalLabel => 'اختياري';

  @override
  String get continueToReview => 'مراجعة العملية';

  @override
  String get reviewStampTitle => 'مراجعة إضافة الطوابع';

  @override
  String get confirmStamp => 'إضافة الطوابع';

  @override
  String get issuingStamps => 'جارٍ إضافة الطوابع بأمان';

  @override
  String get stampSuccessTitle => 'تمت إضافة الطوابع';

  @override
  String stampsIssued(num count) {
    return 'تمت إضافة $count طابع';
  }

  @override
  String get rewardUnlocked => 'تم فتح مكافأة';

  @override
  String get scanNextCustomer => 'مسح العميل التالي';

  @override
  String get rewardsTitle => 'المكافآت المتاحة';

  @override
  String get milestoneReward => 'مكافأة مرحلية';

  @override
  String get finalReward => 'المكافأة النهائية';

  @override
  String thresholdLabel(Object count) {
    return 'الحد: $count طوابع';
  }

  @override
  String expirationLabel(Object date) {
    return 'تنتهي في $date';
  }

  @override
  String redemptionCount(Object count, Object maximum) {
    return 'استُردت $count من $maximum';
  }

  @override
  String get managerApprovalRequired => 'موافقة المدير مطلوبة';

  @override
  String get managerApprovalBody =>
      'اطلب من المالك أو المدير الموافقة على هذه المكافأة تحديداً من منصة التاجر. أبقِ المعاملة مفتوحة ثم تحقق هنا.';

  @override
  String get managerApprovalPending => 'بانتظار موافقة المدير';

  @override
  String get managerApprovalPendingBody =>
      'لم تُسترد المكافأة بعد. يحتفظ وافلو بالطلب الأصلي بأمان حتى يقرر المالك أو المدير من منصة التاجر.';

  @override
  String get managerApprovalChecking => 'جارٍ التحقق من الموافقة';

  @override
  String get managerApprovalCheckingBody =>
      'يتحقق وافلو من طلب المكافأة الأصلي. لا تبدأ عملية استرداد أخرى.';

  @override
  String get managerApprovalCheck => 'التحقق من الموافقة';

  @override
  String get approvalStepRequested => 'طلب الموظف';

  @override
  String get approvalStepMerchant => 'يقرر المدير عبر الويب';

  @override
  String get approvalStepComplete => 'يكمل الموظف هنا';

  @override
  String get managerApprovalRejectedTitle => 'تم رفض الموافقة';

  @override
  String get managerApprovalRejectedBody =>
      'لم تُسترد المكافأة. ابدأ عملية استرداد جديدة فقط إذا كان العميل ما زال يرغب في المتابعة.';

  @override
  String get managerApprovalExpiredTitle => 'انتهت صلاحية الموافقة';

  @override
  String get managerApprovalExpiredBody =>
      'لا يمكن استخدام هذه الموافقة. ابدأ استرداداً جديداً لطلب قرار جديد.';

  @override
  String get managerApprovalConsumedTitle => 'استُخدمت الموافقة مسبقاً';

  @override
  String get managerApprovalConsumedBody =>
      'سيعتمد وافلو أحدث حالة للعميل. لا تستخدم هذه الموافقة في معاملة أخرى.';

  @override
  String get managerApprovalInvalidTitle => 'لا يمكن استخدام الموافقة';

  @override
  String get managerApprovalInvalidBody =>
      'لا تطابق الموافقة طلب المكافأة الآمن هذا. لم يتغير الولاء؛ حدّث حالة العميل أو تواصل مع المالك.';

  @override
  String get managerApprovalStaleTitle => 'تغيّرت تفاصيل المكافأة';

  @override
  String get managerApprovalStaleBody =>
      'تغيّرت المكافأة بعد طلب الموافقة. لم يتم الاسترداد؛ امسح رمز العميل مجدداً.';

  @override
  String get managerApproverInactiveTitle => 'تغيّرت صلاحية المدير';

  @override
  String get managerApproverInactiveBody =>
      'لم يعد المدير الموافق يملك الصلاحية. لم يتم الاسترداد؛ تواصل مع مالك أو مدير نشط.';

  @override
  String get approvalNoMutation =>
      'يبقى ولاء العميل بلا تغيير حتى يؤكد وافلو الاسترداد.';

  @override
  String get startNewRedemption => 'بدء استرداد جديد';

  @override
  String get refreshCustomerState => 'مسح العميل مجدداً';

  @override
  String get redeem => 'استرداد المكافأة';

  @override
  String get redemptionReviewTitle => 'مراجعة استرداد المكافأة';

  @override
  String finalResetWarning(Object goal) {
    return 'بعد الاسترداد ستكتمل هذه الدورة وتعود بطاقة الطوابع إلى 0 من $goal.';
  }

  @override
  String get confirmRedemption => 'تأكيد الاسترداد';

  @override
  String get redeemingReward => 'جارٍ استرداد المكافأة بأمان';

  @override
  String get redemptionSuccessTitle => 'تم استرداد المكافأة';

  @override
  String get progressUnchanged => 'تقدم الطوابع لم يتغير.';

  @override
  String cycleResetComplete(Object goal) {
    return 'اكتملت الدورة وعاد التقدم إلى 0 من $goal.';
  }

  @override
  String get pendingOperationTitle => 'نتيجة العملية قيد الانتظار';

  @override
  String get pendingOperationBody =>
      'لا تبدأ عملية جديدة. تحقق من نتيجة الأمر الأصلي عند توفر الاتصال.';

  @override
  String get checkStatus => 'التحقق من النتيجة';

  @override
  String get dismissRecovery => 'العودة للرئيسية';

  @override
  String get rescanRequired =>
      'امسح عضوية العميل مجدداً قبل إعادة محاولة الأمر نفسه.';

  @override
  String get offlineOperationsBlocked =>
      'تتطلب عمليات الولاء اتصالاً بالإنترنت.';

  @override
  String get noCapabilitiesBody =>
      'هذا الموقع لا يسمح بإضافة الطوابع أو الاسترداد. حدّث سياق الجهاز أو تواصل مع مدير.';

  @override
  String get notAvailableInM2 => 'غير متاح في M2';

  @override
  String get refreshRequired => 'تحديث السياق';

  @override
  String operationReferenceSuffix(Object suffix) {
    return 'مرجع العملية ينتهي بـ $suffix';
  }

  @override
  String get done => 'تم';

  @override
  String get finalReady =>
      'جميع الطوابع ممتلئة. استرد المكافأة النهائية قبل إضافة طوابع أخرى.';

  @override
  String get m2CredentialInvalid =>
      'رمز العضوية غير صالح. اطلب من العميل إظهار رمز جديد.';

  @override
  String get m2MembershipBlocked =>
      'هذه العضوية أو البرنامج غير متاح لعمليات الولاء.';

  @override
  String get m2ProgramMismatch => 'تغيّر البرنامج. امسح العضوية مجدداً.';

  @override
  String get m2LocationBlocked => 'هذه العملية غير مصرح بها في الموقع الحالي.';

  @override
  String get m2StampPolicyBlocked => 'عدد الطوابع المحدد غير مسموح.';

  @override
  String get m2DailyLimit => 'تم بلوغ الحد اليومي للطوابع.';

  @override
  String get m2PurchaseRequired => 'أدخل مبلغ الشراء المطلوب.';

  @override
  String get m2CurrencyMismatch =>
      'استخدم العملة الدقيقة المطلوبة من البرنامج.';

  @override
  String get m2PurchaseThreshold => 'مبلغ الشراء أقل من الحد المطلوب.';

  @override
  String get m2FinalPending =>
      'استرد المكافأة النهائية قبل إصدار طوابع إضافية.';

  @override
  String get m2RewardUnavailable => 'هذه المكافأة لم تعد متاحة.';

  @override
  String get m2RewardExpired => 'انتهت صلاحية هذه المكافأة.';

  @override
  String get m2RewardRedeemed => 'تم استرداد هذه المكافأة مسبقاً.';

  @override
  String get m2ManagerApproval => 'يلزم مسار مدير معتمد، ولن يتجاوزه التطبيق.';

  @override
  String get m2IdempotencyConflict =>
      'تفاصيل العملية الأصلية لا تطابق هذا الأمر. تواصل مع الدعم.';

  @override
  String get m2OperationNotFound => 'لم يتم العثور على الأمر الأصلي.';

  @override
  String get m2OperationProcessing => 'العملية الأصلية ما زالت قيد المعالجة.';

  @override
  String get m2OperationFailed => 'فشلت العملية الأصلية ولم يُسجل نجاح.';

  @override
  String get m2BillingBlocked =>
      'عمليات الولاء متوقفة مؤقتاً لهذا التاجر. لم يتغير تقدم العميل. اطلب من المالك مراجعة الفوترة في منصة التاجر.';

  @override
  String get pairingInternalFailure =>
      'تعذر إكمال الإقران بأمان. جرّب رمز إقران جديداً أو اطلب مساعدة المالك.';

  @override
  String get m2RiskBlocked => 'حظرت وافلو العملية للمراجعة الأمنية.';

  @override
  String get m2RateLimited => 'طلبات كثيرة جداً. انتظر قليلاً ثم تحقق مجدداً.';

  @override
  String get m2ContractError =>
      'أعادت وافلو استجابة غير آمنة أو غير متوافقة، لذا عُطلت العمليات.';

  @override
  String get m2RecoveryExpired =>
      'تحتاج هذه النتيجة المعلقة إلى دعم وافلو قبل محاولة عملية أخرى.';

  @override
  String get m2ResultUnknown =>
      'نتيجة الخادم غير معروفة. لا تكرر العملية، بل تحقق من حالتها.';

  @override
  String get ready => 'جاهز';

  @override
  String get offline => 'غير متصل';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get scanCustomerHelp => 'ضع رمز عضوية العميل داخل الإطار.';

  @override
  String get scannerBlockedPending =>
      'تحقق من المعاملة المعلقة قبل إجراء مسح جديد.';

  @override
  String get checkingTransaction => 'جارٍ التحقق من حالة المعاملة';

  @override
  String get pendingDoNotScanAgain => 'لا تمسح رمز هذا العميل مرة أخرى الآن.';

  @override
  String get checkAgain => 'تحقق مرة أخرى';

  @override
  String get connectionInterruptedAfterSend =>
      'انقطع الاتصال بعد احتمال إرسال الطلب. سيتحقق وافلو من المعاملة الأصلية فقط.';

  @override
  String get requestingCamera => 'جارٍ طلب إذن الكاميرا';

  @override
  String get cameraPermissionRequiredTitle => 'يلزم السماح بالكاميرا';

  @override
  String get cameraPermissionRequiredBody =>
      'اسمح باستخدام الكاميرا لمسح رمز عضوية العميل.';

  @override
  String get cameraPermissionDeniedTitle => 'استخدام الكاميرا متوقف';

  @override
  String get cameraPermissionDeniedBody =>
      'افتح إعدادات الجهاز واسمح لتطبيق وافلو للموظفين باستخدام الكاميرا.';

  @override
  String get scannerReady => 'جاهز للمسح';

  @override
  String get codeDetected => 'تم اكتشاف الرمز';

  @override
  String get scannerResolving => 'جارٍ تحميل بيانات العميل…';

  @override
  String get cameraUnavailable => 'الكاميرا غير متاحة';

  @override
  String get networkUnavailable => 'الشبكة غير متاحة';

  @override
  String get cancelled => 'تم الإلغاء';

  @override
  String get scannerPaused =>
      'توقف الماسح مؤقتاً لأن تطبيق وافلو للموظفين في الخلفية';

  @override
  String get invalidCustomerQr => 'هذا ليس رمز عضوية صالحاً في وافلو.';

  @override
  String get unsupportedCustomerQr =>
      'رمز العضوية هذا غير مدعوم في هذا الإصدار من وافلو للموظفين.';

  @override
  String get membershipNotFound => 'لم يتم العثور على العضوية';

  @override
  String get membershipInactive => 'هذه العضوية غير نشطة.';

  @override
  String get locationNotEligible => 'لا يمكن لهذا الموقع خدمة هذه العضوية.';

  @override
  String get currentProgress => 'التقدم الحالي';

  @override
  String get rewardUnlockNotice => 'فتح المكافأة';

  @override
  String stampsUntilReward(num count) {
    return '$count طوابع حتى المكافأة';
  }

  @override
  String get loyaltyProgressUpdated => 'تم تحديث تقدم الولاء';

  @override
  String get rapidScanMode => 'وضع المسح السريع';

  @override
  String get rapidScanModeBody =>
      'إبراز إجراء مسح العميل التالي بعد نجاح العملية.';

  @override
  String get rapidScanReady =>
      'تُمسح بيانات العميل ومدخلات الشراء قبل فتح الماسح.';

  @override
  String get deviceAndSecurity => 'الجهاز والأمان';

  @override
  String get deviceControls => 'عناصر تحكم الجهاز';

  @override
  String get securityProtected => 'الأمان: محمي';

  @override
  String get securityProtectedBody =>
      'حالة الجهاز وضوابط الخصوصية المحلية مفعّلة.';

  @override
  String get thisDevice => 'هذا الجهاز';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get activeOrganization => 'المؤسسة النشطة';

  @override
  String get lastVerified => 'آخر تحقق';

  @override
  String get appVersionLabel => 'إصدار التطبيق';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get appLockSettings => 'إعدادات قفل التطبيق';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockLocalOnly =>
      'يحمي قفل التطبيق هذا الهاتف فقط، ولا يغيّر دورك أو صلاحيات الخادم.';

  @override
  String get appLockOff => 'متوقف';

  @override
  String get biometric => 'المقاييس الحيوية';

  @override
  String get pinAndBiometrics => 'رمز PIN + المقاييس الحيوية';

  @override
  String get localStaffPin => 'رمز الموظف المحلي';

  @override
  String get lockAfter => 'القفل بعد';

  @override
  String get lockImmediately => 'فوراً';

  @override
  String get afterOneMinute => 'بعد دقيقة واحدة';

  @override
  String get afterFiveMinutes => 'بعد 5 دقائق';

  @override
  String get createLocalStaffPin => 'إنشاء رمز موظف محلي';

  @override
  String get pinNeverManager =>
      'استخدم من 4 إلى 6 أرقام. يفتح هذا الرمز الهاتف فقط ولا يُعد رمز مدير.';

  @override
  String get newPin => 'الرمز الجديد';

  @override
  String get confirmPin => 'تأكيد الرمز';

  @override
  String get savePin => 'حفظ الرمز';

  @override
  String get pinMismatch => 'إدخالا الرمز غير متطابقين.';

  @override
  String get pinLengthHelp => 'أدخل من 4 إلى 6 أرقام.';

  @override
  String get appLocked => 'تطبيق وافلو للموظفين مقفل';

  @override
  String get appLockedBody =>
      'افتح التطبيق للمتابعة. تبقى جلسة الدخول وأي معاملة معلقة محفوظتين بأمان.';

  @override
  String get unlock => 'فتح';

  @override
  String get unlockWithBiometrics => 'فتح بالمقاييس الحيوية';

  @override
  String get biometricUnlockReason => 'فتح تطبيق وافلو للموظفين';

  @override
  String get biometricSetupReason =>
      'أكد المقاييس الحيوية لتفعيل قفل التطبيق المحلي';

  @override
  String get biometricUnavailable =>
      'الفتح بالمقاييس الحيوية غير متاح على هذا الهاتف.';

  @override
  String get createPinFirst => 'أنشئ رمز PIN قبل تفعيل المقاييس الحيوية.';

  @override
  String get enterPinToUnlock => 'أدخل رمز PIN';

  @override
  String get pinUnlockBody =>
      'استخدم رمز الموظف المحلي الذي أنشأته على هذا الهاتف.';

  @override
  String get biometricPinFallback =>
      'لم يتم تأكيد المقاييس الحيوية. أدخل رمز PIN للمتابعة.';

  @override
  String get tryBiometricsAgain => 'حاول استخدام المقاييس الحيوية مجدداً';

  @override
  String get pinRateLimited => 'محاولات كثيرة. انتظر قبل المحاولة مجدداً.';

  @override
  String get unlockFailed => 'تعذر فتح تطبيق وافلو للموظفين. حاول مجدداً.';

  @override
  String get devicePendingTitle => 'موافقة الجهاز معلقة';

  @override
  String get devicePendingBody =>
      'تم إقران الهاتف، لكنه غير جاهز لعمليات العملاء بعد.';

  @override
  String deviceReadyAtLocation(Object location) {
    return 'جاهز في $location';
  }

  @override
  String get serveNextCustomer => 'خدمة العميل التالي';

  @override
  String get appInformation => 'معلومات التطبيق';

  @override
  String get appearanceAndLanguage => 'المظهر واللغة';

  @override
  String get customerDetailsCleared => 'تم مسح بيانات العميل';

  @override
  String get newCycleStarted => 'بدأت دورة جديدة';

  @override
  String get rewardReadyBody =>
      'بطاقة الطوابع مكتملة، ويمكن استرداد المكافأة الآن.';

  @override
  String get reviewDetails => 'مراجعة التفاصيل';

  @override
  String get operationInProgress => 'جارٍ إكمال المعاملة';

  @override
  String get noOfflineQueue =>
      'لم تتم جدولة أي تغيير في الولاء. أعد الاتصال قبل المتابعة.';

  @override
  String get scanFrameLabel => 'إطار مسح رمز عضوية QR';

  @override
  String get flashOn => 'تشغيل الإضاءة';

  @override
  String get flashOff => 'إيقاف الإضاءة';

  @override
  String get reviewAccess => 'الدخول إلى العرض';

  @override
  String get reviewAccessPrompt =>
      'هل تحتاج إلى بيانات تجريبية أو دخول لمراجعة التطبيق؟';

  @override
  String get reviewAccessBody =>
      'استخدم رمز الدخول المرفق مع طلب مراجعة هذا التطبيق.';

  @override
  String get reviewAccessCode => 'رمز دخول المراجعة';

  @override
  String get reviewAccessCodeHint => 'XXXX-XXXX';

  @override
  String get backToPairing => 'العودة إلى إقران الجهاز';

  @override
  String get reviewConnecting => 'جارٍ الاتصال ببيئة المراجعة…';

  @override
  String get reviewAccessInvalid =>
      'تعذر قبول رمز المراجعة. تحقق من الرمز وحاول مجدداً.';

  @override
  String get reviewAccessExpired =>
      'رمز المراجعة هذا لم يعد فعالاً. اطلب رمزاً حالياً.';

  @override
  String get reviewAccessRateLimited =>
      'محاولات كثيرة. انتظر قليلاً قبل المحاولة مجدداً.';

  @override
  String get reviewEnvironmentUnavailable => 'بيئة المراجعة غير متاحة مؤقتاً.';

  @override
  String get demoMode => 'الوضع التجريبي';

  @override
  String get reviewTools => 'سيناريوهات العرض';

  @override
  String get reviewToolsBody =>
      'تستخدم هذه الأدوات بيانات مراجعة خيالية فقط، ولا يمكنها اختيار تاجر أو عميل حقيقي.';

  @override
  String get reviewScenarios => 'سيناريوهات العرض';

  @override
  String get reviewScenarioNew => 'عميل جديد';

  @override
  String get reviewScenarioActive => 'عميل نشط — ٥ من ٨';

  @override
  String get reviewScenarioRewardReady => 'المكافأة جاهزة — ٨ من ٨';

  @override
  String get reviewScenarioManagerApproval => 'موافقة المدير مطلوبة';

  @override
  String get reviewScenarioPurchaseThreshold =>
      'قيمة الشراء لا تبلغ الحد المطلوب';

  @override
  String get reviewScenarioBillingBlocked => 'العمليات موقوفة بسبب الفوترة';

  @override
  String get reviewScenarioInvalidQr => 'رمز عميل غير صالح';

  @override
  String get reviewInvalidQrDetail => 'حالة آمنة لرمز غير صالح في الماسح';

  @override
  String get resetReviewData => 'إعادة ضبط بيانات العرض';

  @override
  String get reviewResetComplete => 'تمت استعادة بيانات العرض.';

  @override
  String get exitDemo => 'الخروج من العرض';

  @override
  String get exitDemoBody =>
      'سيؤدي ذلك إلى مسح جلسة المراجعة والعودة إلى إقران الجهاز.';

  @override
  String get initializingCamera => 'جارٍ تشغيل الكاميرا…';

  @override
  String get customerLoaded => 'تم تحميل بيانات العميل';

  @override
  String get expiredCustomerQr => 'انتهت صلاحية رمز العميل هذا';

  @override
  String get unableToLoadCustomer => 'تعذر تحميل بيانات العميل';

  @override
  String get demoAccess => 'الدخول إلى العرض';

  @override
  String get enterDemo => 'بدء العرض';

  @override
  String get sampleData => 'بيانات تجريبية';

  @override
  String get localDemoAccessBody =>
      'استعرض تجربة وافلو الحقيقية للموظفين باستخدام عملاء تجريبيين ثابتين، من دون إعداد تاجر أو اتصال بالشبكة.';

  @override
  String get localDemoSafetyBody =>
      'يغيّر هذا العرض البيانات التجريبية على هذا الجهاز فقط، ولا يمكنه الوصول إلى تاجر أو عميل حقيقي.';

  @override
  String get demoScenarios => 'سيناريوهات العرض';

  @override
  String get localDemoScenarioBody =>
      'افتح أي شاشة حقيقية في وافلو ببيانات تجريبية آمنة، أو نفّذ مسار المسح والطوابع والمكافأة بالكامل.';

  @override
  String get exitLocalDemoBody =>
      'سيؤدي ذلك إلى مسح جلسة البيانات التجريبية والعودة إلى إقران الجهاز، من دون التأثير في الجلسات الحقيقية.';

  @override
  String get backToDemoScenarios => 'العودة إلى سيناريوهات العرض';

  @override
  String get demoControls => 'عناصر تحكم العرض';

  @override
  String get simulateValidQr => 'محاكاة رمز صالح';

  @override
  String get simulateInvalidQr => 'محاكاة رمز غير صالح';

  @override
  String get simulateExpiredQr => 'محاكاة رمز منتهي';

  @override
  String get simulateNetworkFailure => 'محاكاة تعذر الشبكة';

  @override
  String get resetScanner => 'إعادة ضبط الماسح';

  @override
  String get simulateManagerApproved => 'محاكاة الموافقة';

  @override
  String get demoGroupOverview => 'البدء';

  @override
  String get demoGroupScanner => 'الماسح';

  @override
  String get demoGroupCustomer => 'العميل والولاء';

  @override
  String get demoGroupOperations => 'الطوابع والمكافآت والاسترداد';

  @override
  String get demoGroupSystem => 'الجهاز والتطبيق';

  @override
  String get demoScenarioHome => 'الرئيسية';

  @override
  String get demoScenarioScannerReady => 'الماسح — جاهز';

  @override
  String get demoScenarioScannerDetected => 'الماسح — تم اكتشاف الرمز';

  @override
  String get demoScenarioScannerResolving => 'الماسح — جارٍ تحميل العميل';

  @override
  String get demoScenarioScannerInvalid => 'الماسح — رمز غير صالح';

  @override
  String get demoScenarioScannerExpired => 'الماسح — رمز منتهي الصلاحية';

  @override
  String get demoScenarioScannerNetwork => 'الماسح — تعذر الشبكة';

  @override
  String get demoScenarioScannerPermission => 'الماسح — إذن الكاميرا مرفوض';

  @override
  String get demoScenarioCustomerZero => 'العميل — ٠ من ٨';

  @override
  String get demoScenarioCustomerFive => 'العميل — ٥ من ٨';

  @override
  String get demoScenarioCustomerEight => 'العميل — ٨ من ٨ والمكافأة جاهزة';

  @override
  String get demoScenarioStampConfirm => 'تأكيد إضافة الطابع';

  @override
  String get demoScenarioStampSuccess => 'نجاح إضافة الطابع — ٦ من ٨';

  @override
  String get demoScenarioRedeemConfirm => 'تأكيد استرداد المكافأة';

  @override
  String get demoScenarioApprovalRequired => 'موافقة المدير مطلوبة';

  @override
  String get demoScenarioApprovalPending => 'موافقة المدير معلقة';

  @override
  String get demoScenarioApprovalRejected => 'رفض المدير الموافقة';

  @override
  String get demoScenarioApprovalExpired => 'انتهت مهلة موافقة المدير';

  @override
  String get demoScenarioRedeemSuccess => 'نجاح الاسترداد — العودة إلى ٠ من ٨';

  @override
  String get demoScenarioPurchaseThreshold =>
      'قيمة الشراء لا تبلغ الحد المطلوب';

  @override
  String get demoScenarioBillingBlocked => 'العمليات موقوفة بسبب الفوترة';

  @override
  String get demoScenarioSessionExpired => 'انتهت صلاحية الجلسة';

  @override
  String get demoScenarioDeviceRevoked => 'تم إلغاء الجهاز';

  @override
  String get demoScenarioAppLock => 'قفل التطبيق';

  @override
  String get demoScenarioDeviceSecurity => 'الجهاز والأمان';

  @override
  String get demoScenarioSettings => 'الإعدادات';
}
