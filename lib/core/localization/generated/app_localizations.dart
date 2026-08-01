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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  /// **'Waflo Staff'**
  String get appTitle;

  /// No description provided for @bootProgress.
  ///
  /// In en, this message translates to:
  /// **'Checking this device securely'**
  String get bootProgress;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair this staff device'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Ask an Owner or Manager to create a one-time staff pairing code in the Waflo dashboard.'**
  String get welcomeBody;

  /// No description provided for @scanPairingCode.
  ///
  /// In en, this message translates to:
  /// **'Scan pairing code'**
  String get scanPairingCode;

  /// No description provided for @securitySummary.
  ///
  /// In en, this message translates to:
  /// **'No dashboard password is entered here. This device creates and protects its own security key.'**
  String get securitySummary;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access for pairing'**
  String get cameraTitle;

  /// No description provided for @cameraBody.
  ///
  /// In en, this message translates to:
  /// **'Waflo Staff uses the camera only to scan a one-time staff device pairing code.'**
  String get cameraBody;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off. You can enter the pairing code securely instead.'**
  String get cameraDenied;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan staff pairing code'**
  String get scannerTitle;

  /// No description provided for @scannerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Place the one-time staff pairing code inside the frame.'**
  String get scannerInstructions;

  /// No description provided for @toggleFlash.
  ///
  /// In en, this message translates to:
  /// **'Toggle camera flash'**
  String get toggleFlash;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @enterCodeInstead.
  ///
  /// In en, this message translates to:
  /// **'Enter code instead'**
  String get enterCodeInstead;

  /// No description provided for @manualCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter pairing code'**
  String get manualCodeTitle;

  /// No description provided for @manualCodeHint.
  ///
  /// In en, this message translates to:
  /// **'One-time pairing code'**
  String get manualCodeHint;

  /// No description provided for @submitCode.
  ///
  /// In en, this message translates to:
  /// **'Continue securely'**
  String get submitCode;

  /// No description provided for @invalidPairing.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid Waflo staff pairing code.'**
  String get invalidPairing;

  /// No description provided for @expiredPairing.
  ///
  /// In en, this message translates to:
  /// **'This pairing code has expired. Ask for a new code.'**
  String get expiredPairing;

  /// No description provided for @usedPairing.
  ///
  /// In en, this message translates to:
  /// **'This pairing code was already used. Ask for a new code.'**
  String get usedPairing;

  /// No description provided for @wrongEnvironmentPairing.
  ///
  /// In en, this message translates to:
  /// **'This pairing code belongs to another Waflo environment.'**
  String get wrongEnvironmentPairing;

  /// No description provided for @pairingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Securing this device'**
  String get pairingProgressTitle;

  /// No description provided for @pairingValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating the pairing code'**
  String get pairingValidating;

  /// No description provided for @pairingCreatingIdentity.
  ///
  /// In en, this message translates to:
  /// **'Creating the device security key'**
  String get pairingCreatingIdentity;

  /// No description provided for @pairingClaiming.
  ///
  /// In en, this message translates to:
  /// **'Claiming the pairing session'**
  String get pairingClaiming;

  /// No description provided for @pairingSigning.
  ///
  /// In en, this message translates to:
  /// **'Signing the secure challenge'**
  String get pairingSigning;

  /// No description provided for @pairingCompleting.
  ///
  /// In en, this message translates to:
  /// **'Completing device pairing'**
  String get pairingCompleting;

  /// No description provided for @pairingSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving the secure session'**
  String get pairingSaving;

  /// No description provided for @pairingLoadingContext.
  ///
  /// In en, this message translates to:
  /// **'Loading the assigned device context'**
  String get pairingLoadingContext;

  /// No description provided for @pairingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Device paired'**
  String get pairingSuccessTitle;

  /// No description provided for @pairingSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'This device is ready for authorized Waflo staff use.'**
  String get pairingSuccessBody;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Continue to home'**
  String get goHome;

  /// No description provided for @deviceReady.
  ///
  /// In en, this message translates to:
  /// **'Device ready'**
  String get deviceReady;

  /// No description provided for @verifiedByWaflo.
  ///
  /// In en, this message translates to:
  /// **'Verified by Waflo'**
  String get verifiedByWaflo;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @platformLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformLabel;

  /// No description provided for @platformIos.
  ///
  /// In en, this message translates to:
  /// **'iOS'**
  String get platformIos;

  /// No description provided for @platformAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get platformAndroid;

  /// No description provided for @assignedLocations.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No assigned locations} =1{1 assigned location} other{{count} assigned locations}}'**
  String assignedLocations(num count);

  /// No description provided for @securityStatus.
  ///
  /// In en, this message translates to:
  /// **'Security status'**
  String get securityStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @lastSynchronized.
  ///
  /// In en, this message translates to:
  /// **'Last synchronized {time}'**
  String lastSynchronized(Object time);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @scanCustomer.
  ///
  /// In en, this message translates to:
  /// **'Scan customer'**
  String get scanCustomer;

  /// No description provided for @recentOperations.
  ///
  /// In en, this message translates to:
  /// **'Recent operations'**
  String get recentOperations;

  /// No description provided for @managerApprovals.
  ///
  /// In en, this message translates to:
  /// **'Manager approvals'**
  String get managerApprovals;

  /// No description provided for @availableInNextPhase.
  ///
  /// In en, this message translates to:
  /// **'Not available in M1'**
  String get availableInNextPhase;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device information'**
  String get deviceInformation;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version {version}'**
  String appVersion(Object version);

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment: {environment}'**
  String environment(Object environment);

  /// No description provided for @refreshContext.
  ///
  /// In en, this message translates to:
  /// **'Refresh device context'**
  String get refreshContext;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'The server session and local security key will be removed. A new dashboard pairing code will be required.'**
  String get signOutBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Waflo is unreachable. Cached information cannot authorize operations.'**
  String get offlineBanner;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'This device needs a new pairing code before it can continue.'**
  String get sessionExpiredBody;

  /// No description provided for @deviceRevokedTitle.
  ///
  /// In en, this message translates to:
  /// **'Device revoked'**
  String get deviceRevokedTitle;

  /// No description provided for @deviceRevokedBody.
  ///
  /// In en, this message translates to:
  /// **'This device is no longer authorized. Contact an Owner or Manager.'**
  String get deviceRevokedBody;

  /// No description provided for @deviceCompromisedTitle.
  ///
  /// In en, this message translates to:
  /// **'Device blocked for security'**
  String get deviceCompromisedTitle;

  /// No description provided for @deviceCompromisedBody.
  ///
  /// In en, this message translates to:
  /// **'Waflo blocked this device to protect the merchant account.'**
  String get deviceCompromisedBody;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Install the latest Waflo Staff version to continue securely.'**
  String get updateRequiredBody;

  /// No description provided for @backendUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Waflo is unavailable'**
  String get backendUnavailableTitle;

  /// No description provided for @backendUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again. Your device was not marked revoked.'**
  String get backendUnavailableBody;

  /// No description provided for @configurationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'App configuration error'**
  String get configurationErrorTitle;

  /// No description provided for @configurationErrorBody.
  ///
  /// In en, this message translates to:
  /// **'This build cannot connect safely. Contact Waflo support.'**
  String get configurationErrorBody;

  /// No description provided for @localSecurityErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Local security key unavailable'**
  String get localSecurityErrorTitle;

  /// No description provided for @localSecurityErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The paired key is missing or damaged. A deliberate device reset and new pairing are required.'**
  String get localSecurityErrorBody;

  /// No description provided for @resetForRepair.
  ///
  /// In en, this message translates to:
  /// **'Reset for new pairing'**
  String get resetForRepair;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again safely.'**
  String get genericError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Check the submitted pairing information.'**
  String get validationError;

  /// No description provided for @signatureError.
  ///
  /// In en, this message translates to:
  /// **'The secure device request could not be verified.'**
  String get signatureError;

  /// No description provided for @clockSkewError.
  ///
  /// In en, this message translates to:
  /// **'Turn on automatic date and time, then try again.'**
  String get clockSkewError;

  /// No description provided for @nonceReplayError.
  ///
  /// In en, this message translates to:
  /// **'The request was already used. A fresh secure request is required.'**
  String get nonceReplayError;

  /// No description provided for @assignmentRequiredError.
  ///
  /// In en, this message translates to:
  /// **'An active staff assignment is required for this device.'**
  String get assignmentRequiredError;

  /// No description provided for @locationNotAuthorizedError.
  ///
  /// In en, this message translates to:
  /// **'This device is not authorized for that location.'**
  String get locationNotAuthorizedError;

  /// No description provided for @riskBlockedError.
  ///
  /// In en, this message translates to:
  /// **'Waflo blocked this request for security review.'**
  String get riskBlockedError;

  /// No description provided for @requestReference.
  ///
  /// In en, this message translates to:
  /// **'Request reference: {requestId}'**
  String requestReference(Object requestId);
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
