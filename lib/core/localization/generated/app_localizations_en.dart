// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Waflo Staff';

  @override
  String get bootProgress => 'Checking this device securely';

  @override
  String get welcomeTitle => 'Pair this staff device';

  @override
  String get welcomeBody =>
      'Ask an Owner or Manager to create a one-time staff pairing code in the Waflo dashboard.';

  @override
  String get scanPairingCode => 'Scan pairing code';

  @override
  String get securitySummary =>
      'No dashboard password is entered here. This device creates and protects its own security key.';

  @override
  String get chooseLanguage => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get cameraTitle => 'Camera access for pairing';

  @override
  String get cameraBody =>
      'Waflo Staff uses the camera only to scan a one-time staff device pairing code.';

  @override
  String get continueAction => 'Continue';

  @override
  String get notNow => 'Not now';

  @override
  String get openSettings => 'Open settings';

  @override
  String get cameraDenied =>
      'Camera access is off. You can enter the pairing code securely instead.';

  @override
  String get scannerTitle => 'Scan staff pairing code';

  @override
  String get scannerInstructions =>
      'Place the one-time staff pairing code inside the frame.';

  @override
  String get toggleFlash => 'Toggle camera flash';

  @override
  String get close => 'Close';

  @override
  String get enterCodeInstead => 'Enter code instead';

  @override
  String get manualCodeTitle => 'Enter pairing code';

  @override
  String get manualCodeHint => 'One-time pairing code';

  @override
  String get submitCode => 'Continue securely';

  @override
  String get invalidPairing => 'This is not a valid Waflo staff pairing code.';

  @override
  String get expiredPairing =>
      'This pairing code has expired. Ask for a new code.';

  @override
  String get usedPairing =>
      'This pairing code was already used. Ask for a new code.';

  @override
  String get wrongEnvironmentPairing =>
      'This pairing code belongs to another Waflo environment.';

  @override
  String get pairingProgressTitle => 'Securing this device';

  @override
  String get pairingValidating => 'Validating the pairing code';

  @override
  String get pairingCreatingIdentity => 'Creating the device security key';

  @override
  String get pairingClaiming => 'Claiming the pairing session';

  @override
  String get pairingSigning => 'Signing the secure challenge';

  @override
  String get pairingCompleting => 'Completing device pairing';

  @override
  String get pairingSaving => 'Saving the secure session';

  @override
  String get pairingLoadingContext => 'Loading the assigned device context';

  @override
  String get pairingSuccessTitle => 'Device paired';

  @override
  String get pairingSuccessBody =>
      'This device is ready for authorized Waflo staff use.';

  @override
  String get goHome => 'Continue to home';

  @override
  String get deviceReady => 'Device ready';

  @override
  String get verifiedByWaflo => 'Verified by Waflo';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleStaff => 'Staff';

  @override
  String get platformLabel => 'Platform';

  @override
  String get platformIos => 'iOS';

  @override
  String get platformAndroid => 'Android';

  @override
  String assignedLocations(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assigned locations',
      one: '1 assigned location',
      zero: 'No assigned locations',
    );
    return '$_temp0';
  }

  @override
  String get securityStatus => 'Security status';

  @override
  String get active => 'Active';

  @override
  String lastSynchronized(Object time) {
    return 'Last synchronized $time';
  }

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get scanCustomer => 'Scan customer';

  @override
  String get recentOperations => 'Recent operations';

  @override
  String get managerApprovals => 'Manager approvals';

  @override
  String get availableInNextPhase => 'Not available in M1';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get deviceInformation => 'Device information';

  @override
  String appVersion(Object version) {
    return 'App version $version';
  }

  @override
  String environment(Object environment) {
    return 'Environment: $environment';
  }

  @override
  String get refreshContext => 'Refresh device context';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out of this device?';

  @override
  String get signOutBody =>
      'The server session and local security key will be removed. A new dashboard pairing code will be required.';

  @override
  String get cancel => 'Cancel';

  @override
  String get privacy => 'Privacy';

  @override
  String get support => 'Support';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get offlineBanner =>
      'Waflo is unreachable. Cached information cannot authorize operations.';

  @override
  String get retry => 'Try again';

  @override
  String get sessionExpiredTitle => 'Session expired';

  @override
  String get sessionExpiredBody =>
      'This device needs a new pairing code before it can continue.';

  @override
  String get deviceRevokedTitle => 'Device revoked';

  @override
  String get deviceRevokedBody =>
      'This device is no longer authorized. Contact an Owner or Manager.';

  @override
  String get deviceCompromisedTitle => 'Device blocked for security';

  @override
  String get deviceCompromisedBody =>
      'Waflo blocked this device to protect the merchant account.';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'Install the latest Waflo Staff version to continue securely.';

  @override
  String get backendUnavailableTitle => 'Waflo is unavailable';

  @override
  String get backendUnavailableBody =>
      'Check your connection and try again. Your device was not marked revoked.';

  @override
  String get configurationErrorTitle => 'App configuration error';

  @override
  String get configurationErrorBody =>
      'This build cannot connect safely. Contact Waflo support.';

  @override
  String get localSecurityErrorTitle => 'Local security key unavailable';

  @override
  String get localSecurityErrorBody =>
      'The paired key is missing or damaged. A deliberate device reset and new pairing are required.';

  @override
  String get resetForRepair => 'Reset for new pairing';

  @override
  String get genericError => 'Something went wrong. Try again safely.';

  @override
  String get validationError => 'Check the submitted pairing information.';

  @override
  String get signatureError =>
      'The secure device request could not be verified.';

  @override
  String get clockSkewError =>
      'Turn on automatic date and time, then try again.';

  @override
  String get nonceReplayError =>
      'The request was already used. A fresh secure request is required.';

  @override
  String get assignmentRequiredError =>
      'An active staff assignment is required for this device.';

  @override
  String get locationNotAuthorizedError =>
      'This device is not authorized for that location.';

  @override
  String get riskBlockedError =>
      'Waflo blocked this request for security review.';

  @override
  String requestReference(Object requestId) {
    return 'Request reference: $requestId';
  }
}
