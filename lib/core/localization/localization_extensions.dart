import 'package:waflo_staff/core/localization/generated/app_localizations.dart';

extension WafloLocalizationX on AppLocalizations {
  String localizeRole(String role) => switch (role) {
    'OWNER' => roleOwner,
    'MANAGER' => roleManager,
    'STAFF' => roleStaff,
    _ => verifiedByWaflo,
  };

  String localizePlatform(String platform) => switch (platform) {
    'IOS' => platformIos,
    'ANDROID' => platformAndroid,
    _ => verifiedByWaflo,
  };
}
