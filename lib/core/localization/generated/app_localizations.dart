import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

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
    Locale('ckb'),
    Locale('en'),
    Locale('ku'),
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

  /// No description provided for @kurdishGroup.
  ///
  /// In en, this message translates to:
  /// **'کوردی'**
  String get kurdishGroup;

  /// No description provided for @kurdishBadini.
  ///
  /// In en, this message translates to:
  /// **'بادینی'**
  String get kurdishBadini;

  /// No description provided for @kurdishSorani.
  ///
  /// In en, this message translates to:
  /// **'سۆرانی'**
  String get kurdishSorani;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access for pairing'**
  String get cameraTitle;

  /// No description provided for @cameraBody.
  ///
  /// In en, this message translates to:
  /// **'Waflo Staff uses the camera to scan staff pairing codes and customer membership codes.'**
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

  /// No description provided for @pairingRecovering.
  ///
  /// In en, this message translates to:
  /// **'Recovering the secure pairing challenge'**
  String get pairingRecovering;

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

  /// No description provided for @organizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organizationLabel;

  /// No description provided for @staffLabel.
  ///
  /// In en, this message translates to:
  /// **'Staff member'**
  String get staffLabel;

  /// No description provided for @deviceStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Device status'**
  String get deviceStatusLabel;

  /// No description provided for @currentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocationLabel;

  /// No description provided for @locationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned locations'**
  String get locationsTitle;

  /// No description provided for @earningCapability.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get earningCapability;

  /// No description provided for @redemptionCapability.
  ///
  /// In en, this message translates to:
  /// **'Redemption'**
  String get redemptionCapability;

  /// No description provided for @capabilityAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get capabilityAllowed;

  /// No description provided for @capabilityBlocked.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get capabilityBlocked;

  /// No description provided for @updatePolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Update policy'**
  String get updatePolicyLabel;

  /// No description provided for @minimumSupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'Minimum supported version: {version}'**
  String minimumSupportedVersion(Object version);

  /// No description provided for @appVersionCurrent.
  ///
  /// In en, this message translates to:
  /// **'This app version is supported'**
  String get appVersionCurrent;

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

  /// No description provided for @homeHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Every visit counts'**
  String get homeHeaderTitle;

  /// No description provided for @homeHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the customer and let Waflo handle the rest.'**
  String get homeHeaderSubtitle;

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
  /// **'System'**
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

  /// No description provided for @staffUserDeactivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff access deactivated'**
  String get staffUserDeactivatedTitle;

  /// No description provided for @staffUserDeactivatedBody.
  ///
  /// In en, this message translates to:
  /// **'This Staff identity is no longer active. Ask an Owner to restore access, then pair this phone again.'**
  String get staffUserDeactivatedBody;

  /// No description provided for @staffMembershipInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff membership inactive'**
  String get staffMembershipInactiveTitle;

  /// No description provided for @staffMembershipInactiveBody.
  ///
  /// In en, this message translates to:
  /// **'Access to this merchant is no longer active. Contact an Owner or Manager, then pair this phone again.'**
  String get staffMembershipInactiveBody;

  /// No description provided for @staffLocationInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access removed'**
  String get staffLocationInvalidTitle;

  /// No description provided for @staffLocationInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'This phone is no longer assigned to its paired location. Ask an Owner or Manager to assign and pair it again.'**
  String get staffLocationInvalidBody;

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

  /// No description provided for @pairDeviceAgain.
  ///
  /// In en, this message translates to:
  /// **'Pair device again'**
  String get pairDeviceAgain;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again safely.'**
  String get genericError;

  /// No description provided for @operationNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Operation not completed'**
  String get operationNotCompleted;

  /// No description provided for @customerOperationsPaused.
  ///
  /// In en, this message translates to:
  /// **'Customer operations are paused'**
  String get customerOperationsPaused;

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

  /// No description provided for @m2ScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan customer'**
  String get m2ScannerTitle;

  /// No description provided for @m2ScannerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Place the customer Waflo membership QR inside the frame. The code is not displayed or saved.'**
  String get m2ScannerInstructions;

  /// No description provided for @resolvingMembership.
  ///
  /// In en, this message translates to:
  /// **'Resolving membership securely'**
  String get resolvingMembership;

  /// No description provided for @membershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membershipTitle;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @programLabel.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get programLabel;

  /// No description provided for @membershipStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Membership status'**
  String get membershipStatusLabel;

  /// No description provided for @membershipStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get membershipStatusActive;

  /// No description provided for @membershipStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get membershipStatusSuspended;

  /// No description provided for @membershipStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get membershipStatusExpired;

  /// No description provided for @membershipStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get membershipStatusRevoked;

  /// No description provided for @progressOf.
  ///
  /// In en, this message translates to:
  /// **'{progress} of {goal} stamps'**
  String progressOf(Object goal, Object progress);

  /// No description provided for @completedCycles.
  ///
  /// In en, this message translates to:
  /// **'Completed cycles: {count}'**
  String completedCycles(Object count);

  /// No description provided for @resolvedAt.
  ///
  /// In en, this message translates to:
  /// **'Resolved {time}'**
  String resolvedAt(Object time);

  /// No description provided for @rewardReady.
  ///
  /// In en, this message translates to:
  /// **'Final reward ready'**
  String get rewardReady;

  /// No description provided for @earningAvailable.
  ///
  /// In en, this message translates to:
  /// **'Earning is available here'**
  String get earningAvailable;

  /// No description provided for @redemptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Redemption is available here'**
  String get redemptionAvailable;

  /// No description provided for @stampAmount.
  ///
  /// In en, this message translates to:
  /// **'Stamp amount'**
  String get stampAmount;

  /// No description provided for @projectedProgress.
  ///
  /// In en, this message translates to:
  /// **'After approval: {progress} of {goal}'**
  String projectedProgress(Object goal, Object progress);

  /// No description provided for @purchaseAmount.
  ///
  /// In en, this message translates to:
  /// **'Purchase amount'**
  String get purchaseAmount;

  /// No description provided for @requiredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Required currency: {currency}'**
  String requiredCurrency(Object currency);

  /// No description provided for @purchaseMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum purchase: {amount}'**
  String purchaseMinimum(Object amount);

  /// No description provided for @transactionReference.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference'**
  String get transactionReference;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @continueToReview.
  ///
  /// In en, this message translates to:
  /// **'Review operation'**
  String get continueToReview;

  /// No description provided for @reviewStampTitle.
  ///
  /// In en, this message translates to:
  /// **'Review stamps'**
  String get reviewStampTitle;

  /// No description provided for @confirmStamp.
  ///
  /// In en, this message translates to:
  /// **'Add stamps'**
  String get confirmStamp;

  /// No description provided for @issuingStamps.
  ///
  /// In en, this message translates to:
  /// **'Adding stamps securely'**
  String get issuingStamps;

  /// No description provided for @stampSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Stamps added'**
  String get stampSuccessTitle;

  /// No description provided for @stampsIssued.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stamp added} other{{count} stamps added}}'**
  String stampsIssued(num count);

  /// No description provided for @rewardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Reward unlocked'**
  String get rewardUnlocked;

  /// No description provided for @scanNextCustomer.
  ///
  /// In en, this message translates to:
  /// **'Scan next customer'**
  String get scanNextCustomer;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available rewards'**
  String get rewardsTitle;

  /// No description provided for @milestoneReward.
  ///
  /// In en, this message translates to:
  /// **'Milestone reward'**
  String get milestoneReward;

  /// No description provided for @finalReward.
  ///
  /// In en, this message translates to:
  /// **'Final reward'**
  String get finalReward;

  /// No description provided for @thresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold: {count} stamps'**
  String thresholdLabel(Object count);

  /// No description provided for @expirationLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expirationLabel(Object date);

  /// No description provided for @redemptionCount.
  ///
  /// In en, this message translates to:
  /// **'Redeemed {count} of {maximum}'**
  String redemptionCount(Object count, Object maximum);

  /// No description provided for @managerApprovalRequired.
  ///
  /// In en, this message translates to:
  /// **'Manager approval required'**
  String get managerApprovalRequired;

  /// No description provided for @managerApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'Ask an Owner or Manager to approve this exact reward in Merchant Web. Keep this transaction open, then check again here.'**
  String get managerApprovalBody;

  /// No description provided for @managerApprovalPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for manager approval'**
  String get managerApprovalPending;

  /// No description provided for @managerApprovalPendingBody.
  ///
  /// In en, this message translates to:
  /// **'No reward has been redeemed yet. The original request is held safely while an Owner or Manager decides in Merchant Web.'**
  String get managerApprovalPendingBody;

  /// No description provided for @managerApprovalChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking approval'**
  String get managerApprovalChecking;

  /// No description provided for @managerApprovalCheckingBody.
  ///
  /// In en, this message translates to:
  /// **'Waflo is checking the original reward request. Do not start another redemption.'**
  String get managerApprovalCheckingBody;

  /// No description provided for @managerApprovalCheck.
  ///
  /// In en, this message translates to:
  /// **'Check approval'**
  String get managerApprovalCheck;

  /// No description provided for @approvalStepRequested.
  ///
  /// In en, this message translates to:
  /// **'Staff requested'**
  String get approvalStepRequested;

  /// No description provided for @approvalStepMerchant.
  ///
  /// In en, this message translates to:
  /// **'Manager decides on Web'**
  String get approvalStepMerchant;

  /// No description provided for @approvalStepComplete.
  ///
  /// In en, this message translates to:
  /// **'Staff completes here'**
  String get approvalStepComplete;

  /// No description provided for @managerApprovalRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval declined'**
  String get managerApprovalRejectedTitle;

  /// No description provided for @managerApprovalRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'The reward was not redeemed. Start a new deliberate redemption only if the customer still wants to continue.'**
  String get managerApprovalRejectedBody;

  /// No description provided for @managerApprovalExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval expired'**
  String get managerApprovalExpiredTitle;

  /// No description provided for @managerApprovalExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'This approval can no longer be used. Start a new redemption to request a fresh decision.'**
  String get managerApprovalExpiredBody;

  /// No description provided for @managerApprovalConsumedTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval already used'**
  String get managerApprovalConsumedTitle;

  /// No description provided for @managerApprovalConsumedBody.
  ///
  /// In en, this message translates to:
  /// **'Waflo will use the latest customer state. Do not reuse this approval for another transaction.'**
  String get managerApprovalConsumedBody;

  /// No description provided for @managerApprovalInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval cannot be used'**
  String get managerApprovalInvalidTitle;

  /// No description provided for @managerApprovalInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'The approval does not match this secure reward request. No loyalty change was made; refresh the customer state or contact an Owner.'**
  String get managerApprovalInvalidBody;

  /// No description provided for @managerApprovalStaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward details changed'**
  String get managerApprovalStaleTitle;

  /// No description provided for @managerApprovalStaleBody.
  ///
  /// In en, this message translates to:
  /// **'The reward changed after approval was requested. No redemption was made; scan the customer again.'**
  String get managerApprovalStaleBody;

  /// No description provided for @managerApproverInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Manager access changed'**
  String get managerApproverInactiveTitle;

  /// No description provided for @managerApproverInactiveBody.
  ///
  /// In en, this message translates to:
  /// **'The approving Manager no longer has permission. No redemption was made; contact an active Owner or Manager.'**
  String get managerApproverInactiveBody;

  /// No description provided for @approvalNoMutation.
  ///
  /// In en, this message translates to:
  /// **'Customer loyalty remains unchanged until Waflo confirms redemption.'**
  String get approvalNoMutation;

  /// No description provided for @startNewRedemption.
  ///
  /// In en, this message translates to:
  /// **'Start new redemption'**
  String get startNewRedemption;

  /// No description provided for @refreshCustomerState.
  ///
  /// In en, this message translates to:
  /// **'Scan customer again'**
  String get refreshCustomerState;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem reward'**
  String get redeem;

  /// No description provided for @redemptionReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review reward redemption'**
  String get redemptionReviewTitle;

  /// No description provided for @finalResetWarning.
  ///
  /// In en, this message translates to:
  /// **'After redemption, this cycle will complete and the stamp card will reset to 0 of {goal}.'**
  String finalResetWarning(Object goal);

  /// No description provided for @confirmRedemption.
  ///
  /// In en, this message translates to:
  /// **'Confirm redemption'**
  String get confirmRedemption;

  /// No description provided for @redeemingReward.
  ///
  /// In en, this message translates to:
  /// **'Redeeming reward securely'**
  String get redeemingReward;

  /// No description provided for @redemptionSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward redeemed'**
  String get redemptionSuccessTitle;

  /// No description provided for @progressUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Stamp progress is unchanged.'**
  String get progressUnchanged;

  /// No description provided for @cycleResetComplete.
  ///
  /// In en, this message translates to:
  /// **'Cycle completed. Progress reset to 0 of {goal}.'**
  String cycleResetComplete(Object goal);

  /// No description provided for @pendingOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation result pending'**
  String get pendingOperationTitle;

  /// No description provided for @pendingOperationBody.
  ///
  /// In en, this message translates to:
  /// **'Do not start a new operation. Check the original command result when the connection is available.'**
  String get pendingOperationBody;

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Check result'**
  String get checkStatus;

  /// No description provided for @dismissRecovery.
  ///
  /// In en, this message translates to:
  /// **'Return home'**
  String get dismissRecovery;

  /// No description provided for @rescanRequired.
  ///
  /// In en, this message translates to:
  /// **'Scan the customer membership again before retrying the same command.'**
  String get rescanRequired;

  /// No description provided for @offlineOperationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Loyalty operations require an online connection.'**
  String get offlineOperationsBlocked;

  /// No description provided for @noCapabilitiesBody.
  ///
  /// In en, this message translates to:
  /// **'This location permits neither earning nor redemption. Refresh the device context or contact a Manager.'**
  String get noCapabilitiesBody;

  /// No description provided for @notAvailableInM2.
  ///
  /// In en, this message translates to:
  /// **'Not available in M2'**
  String get notAvailableInM2;

  /// No description provided for @refreshRequired.
  ///
  /// In en, this message translates to:
  /// **'Refresh context'**
  String get refreshRequired;

  /// No description provided for @operationReferenceSuffix.
  ///
  /// In en, this message translates to:
  /// **'Operation reference ending {suffix}'**
  String operationReferenceSuffix(Object suffix);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @finalReady.
  ///
  /// In en, this message translates to:
  /// **'All stamps are filled. Redeem the final reward before earning more.'**
  String get finalReady;

  /// No description provided for @m2CredentialInvalid.
  ///
  /// In en, this message translates to:
  /// **'This membership code is invalid. Ask the customer to show a fresh code.'**
  String get m2CredentialInvalid;

  /// No description provided for @m2MembershipBlocked.
  ///
  /// In en, this message translates to:
  /// **'This membership or program is not available for loyalty operations.'**
  String get m2MembershipBlocked;

  /// No description provided for @m2ProgramMismatch.
  ///
  /// In en, this message translates to:
  /// **'The program changed. Scan the membership again.'**
  String get m2ProgramMismatch;

  /// No description provided for @m2LocationBlocked.
  ///
  /// In en, this message translates to:
  /// **'This operation is not authorized at the current location.'**
  String get m2LocationBlocked;

  /// No description provided for @m2StampPolicyBlocked.
  ///
  /// In en, this message translates to:
  /// **'The selected stamp amount is not permitted.'**
  String get m2StampPolicyBlocked;

  /// No description provided for @m2DailyLimit.
  ///
  /// In en, this message translates to:
  /// **'The daily stamp allowance has been reached.'**
  String get m2DailyLimit;

  /// No description provided for @m2PurchaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the required purchase amount.'**
  String get m2PurchaseRequired;

  /// No description provided for @m2CurrencyMismatch.
  ///
  /// In en, this message translates to:
  /// **'Use the exact currency required by the program.'**
  String get m2CurrencyMismatch;

  /// No description provided for @m2PurchaseThreshold.
  ///
  /// In en, this message translates to:
  /// **'The purchase amount does not meet the required minimum.'**
  String get m2PurchaseThreshold;

  /// No description provided for @m2FinalPending.
  ///
  /// In en, this message translates to:
  /// **'Redeem the final reward before issuing more stamps.'**
  String get m2FinalPending;

  /// No description provided for @m2RewardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This reward is no longer available.'**
  String get m2RewardUnavailable;

  /// No description provided for @m2RewardExpired.
  ///
  /// In en, this message translates to:
  /// **'This reward has expired.'**
  String get m2RewardExpired;

  /// No description provided for @m2RewardRedeemed.
  ///
  /// In en, this message translates to:
  /// **'This reward was already redeemed.'**
  String get m2RewardRedeemed;

  /// No description provided for @m2ManagerApproval.
  ///
  /// In en, this message translates to:
  /// **'An approved Manager flow is required. This app will not bypass it.'**
  String get m2ManagerApproval;

  /// No description provided for @m2IdempotencyConflict.
  ///
  /// In en, this message translates to:
  /// **'The original operation details do not match this command. Contact support.'**
  String get m2IdempotencyConflict;

  /// No description provided for @m2OperationNotFound.
  ///
  /// In en, this message translates to:
  /// **'The original command was not found.'**
  String get m2OperationNotFound;

  /// No description provided for @m2OperationProcessing.
  ///
  /// In en, this message translates to:
  /// **'The original operation is still processing.'**
  String get m2OperationProcessing;

  /// No description provided for @m2OperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The original operation failed and no success was recorded.'**
  String get m2OperationFailed;

  /// No description provided for @m2BillingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Loyalty operations are paused for this merchant. No customer progress changed. Ask an Owner to review billing in Merchant Web.'**
  String get m2BillingBlocked;

  /// No description provided for @pairingInternalFailure.
  ///
  /// In en, this message translates to:
  /// **'Pairing could not be completed safely. Try a fresh pairing code or ask an Owner for help.'**
  String get pairingInternalFailure;

  /// No description provided for @m2RiskBlocked.
  ///
  /// In en, this message translates to:
  /// **'Waflo blocked this operation for security review.'**
  String get m2RiskBlocked;

  /// No description provided for @m2RateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait briefly, then check again.'**
  String get m2RateLimited;

  /// No description provided for @m2ContractError.
  ///
  /// In en, this message translates to:
  /// **'Waflo returned an unsafe or incompatible response. Operations are disabled.'**
  String get m2ContractError;

  /// No description provided for @m2RecoveryExpired.
  ///
  /// In en, this message translates to:
  /// **'This pending result needs Waflo support before another operation is attempted.'**
  String get m2RecoveryExpired;

  /// No description provided for @m2ResultUnknown.
  ///
  /// In en, this message translates to:
  /// **'The server result is unknown. Do not repeat the operation; check its status.'**
  String get m2ResultUnknown;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @scanCustomerHelp.
  ///
  /// In en, this message translates to:
  /// **'Hold the customer’s membership code inside the frame.'**
  String get scanCustomerHelp;

  /// No description provided for @scannerBlockedPending.
  ///
  /// In en, this message translates to:
  /// **'Resolve the pending transaction before scanning again.'**
  String get scannerBlockedPending;

  /// No description provided for @checkingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Checking transaction status'**
  String get checkingTransaction;

  /// No description provided for @pendingDoNotScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not scan this customer again yet.'**
  String get pendingDoNotScanAgain;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @connectionInterruptedAfterSend.
  ///
  /// In en, this message translates to:
  /// **'The connection was interrupted after the request may have been sent. Waflo will check the original transaction only.'**
  String get connectionInterruptedAfterSend;

  /// No description provided for @requestingCamera.
  ///
  /// In en, this message translates to:
  /// **'Requesting camera access'**
  String get requestingCamera;

  /// No description provided for @cameraPermissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get cameraPermissionRequiredTitle;

  /// No description provided for @cameraPermissionRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to scan the customer’s membership code.'**
  String get cameraPermissionRequiredBody;

  /// No description provided for @cameraPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get cameraPermissionDeniedTitle;

  /// No description provided for @cameraPermissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Open device settings and allow camera access for Waflo Staff.'**
  String get cameraPermissionDeniedBody;

  /// No description provided for @scannerReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get scannerReady;

  /// No description provided for @codeDetected.
  ///
  /// In en, this message translates to:
  /// **'Code detected'**
  String get codeDetected;

  /// No description provided for @scannerResolving.
  ///
  /// In en, this message translates to:
  /// **'Loading customer…'**
  String get scannerResolving;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraUnavailable;

  /// No description provided for @networkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable'**
  String get networkUnavailable;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @scannerPaused.
  ///
  /// In en, this message translates to:
  /// **'Scanner paused while Waflo Staff is in the background'**
  String get scannerPaused;

  /// No description provided for @invalidCustomerQr.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid Waflo membership code.'**
  String get invalidCustomerQr;

  /// No description provided for @unsupportedCustomerQr.
  ///
  /// In en, this message translates to:
  /// **'This membership code is not supported by this version of Waflo Staff.'**
  String get unsupportedCustomerQr;

  /// No description provided for @membershipNotFound.
  ///
  /// In en, this message translates to:
  /// **'Membership not found'**
  String get membershipNotFound;

  /// No description provided for @membershipInactive.
  ///
  /// In en, this message translates to:
  /// **'This membership is not active.'**
  String get membershipInactive;

  /// No description provided for @locationNotEligible.
  ///
  /// In en, this message translates to:
  /// **'This location cannot serve this membership.'**
  String get locationNotEligible;

  /// No description provided for @currentProgress.
  ///
  /// In en, this message translates to:
  /// **'Current progress'**
  String get currentProgress;

  /// No description provided for @rewardUnlockNotice.
  ///
  /// In en, this message translates to:
  /// **'Reward unlock'**
  String get rewardUnlockNotice;

  /// No description provided for @stampsUntilReward.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stamp until reward} other{{count} stamps until reward}}'**
  String stampsUntilReward(num count);

  /// No description provided for @loyaltyProgressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Loyalty progress updated'**
  String get loyaltyProgressUpdated;

  /// No description provided for @rapidScanMode.
  ///
  /// In en, this message translates to:
  /// **'Rapid scan mode'**
  String get rapidScanMode;

  /// No description provided for @rapidScanModeBody.
  ///
  /// In en, this message translates to:
  /// **'Keep Scan next customer as the main action after success.'**
  String get rapidScanModeBody;

  /// No description provided for @rapidScanReady.
  ///
  /// In en, this message translates to:
  /// **'Customer details and purchase inputs are cleared before the scanner opens.'**
  String get rapidScanReady;

  /// No description provided for @deviceAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Device & Security'**
  String get deviceAndSecurity;

  /// No description provided for @deviceControls.
  ///
  /// In en, this message translates to:
  /// **'Device controls'**
  String get deviceControls;

  /// No description provided for @securityProtected.
  ///
  /// In en, this message translates to:
  /// **'Security: Protected'**
  String get securityProtected;

  /// No description provided for @securityProtectedBody.
  ///
  /// In en, this message translates to:
  /// **'Device status and local privacy controls are active.'**
  String get securityProtectedBody;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @activeOrganization.
  ///
  /// In en, this message translates to:
  /// **'Active organization'**
  String get activeOrganization;

  /// No description provided for @lastVerified.
  ///
  /// In en, this message translates to:
  /// **'Last verified'**
  String get lastVerified;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersionLabel;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @appLockSettings.
  ///
  /// In en, this message translates to:
  /// **'App lock settings'**
  String get appLockSettings;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'App lock protects this phone only. It does not change your Waflo role or server permissions.'**
  String get appLockLocalOnly;

  /// No description provided for @appLockOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get appLockOff;

  /// No description provided for @biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometric;

  /// No description provided for @pinAndBiometrics.
  ///
  /// In en, this message translates to:
  /// **'PIN + biometrics'**
  String get pinAndBiometrics;

  /// No description provided for @localStaffPin.
  ///
  /// In en, this message translates to:
  /// **'Local Staff PIN'**
  String get localStaffPin;

  /// No description provided for @lockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get lockAfter;

  /// No description provided for @lockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockImmediately;

  /// No description provided for @afterOneMinute.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get afterOneMinute;

  /// No description provided for @afterFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get afterFiveMinutes;

  /// No description provided for @createLocalStaffPin.
  ///
  /// In en, this message translates to:
  /// **'Create Local Staff PIN'**
  String get createLocalStaffPin;

  /// No description provided for @pinNeverManager.
  ///
  /// In en, this message translates to:
  /// **'Use 4–6 digits. This unlocks this phone only and is never a Manager PIN.'**
  String get pinNeverManager;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @savePin.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get savePin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PIN entries do not match.'**
  String get pinMismatch;

  /// No description provided for @pinLengthHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter 4–6 digits.'**
  String get pinLengthHelp;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Waflo Staff is locked'**
  String get appLocked;

  /// No description provided for @appLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue. Your signed-in session and any pending transaction remain safely preserved.'**
  String get appLockedBody;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockWithBiometrics;

  /// No description provided for @biometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Waflo Staff'**
  String get biometricUnlockReason;

  /// No description provided for @biometricSetupReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm biometrics to enable local app lock'**
  String get biometricSetupReason;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock is not available on this phone.'**
  String get biometricUnavailable;

  /// No description provided for @createPinFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN before enabling biometrics.'**
  String get createPinFirst;

  /// No description provided for @enterPinToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPinToUnlock;

  /// No description provided for @pinUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Use the local Staff PIN created on this phone.'**
  String get pinUnlockBody;

  /// No description provided for @biometricPinFallback.
  ///
  /// In en, this message translates to:
  /// **'Biometrics weren’t confirmed. Enter your PIN to continue.'**
  String get biometricPinFallback;

  /// No description provided for @tryBiometricsAgain.
  ///
  /// In en, this message translates to:
  /// **'Try biometrics again'**
  String get tryBiometricsAgain;

  /// No description provided for @pinRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait before trying again.'**
  String get pinRateLimited;

  /// No description provided for @unlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Waflo Staff could not be unlocked. Try again.'**
  String get unlockFailed;

  /// No description provided for @devicePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Device approval pending'**
  String get devicePendingTitle;

  /// No description provided for @devicePendingBody.
  ///
  /// In en, this message translates to:
  /// **'This phone is paired, but it is not ready for customer operations yet.'**
  String get devicePendingBody;

  /// No description provided for @deviceReadyAtLocation.
  ///
  /// In en, this message translates to:
  /// **'Ready at {location}'**
  String deviceReadyAtLocation(Object location);

  /// No description provided for @serveNextCustomer.
  ///
  /// In en, this message translates to:
  /// **'Serve the next customer'**
  String get serveNextCustomer;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformation;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance & language'**
  String get appearanceAndLanguage;

  /// No description provided for @customerDetailsCleared.
  ///
  /// In en, this message translates to:
  /// **'Customer details cleared'**
  String get customerDetailsCleared;

  /// No description provided for @newCycleStarted.
  ///
  /// In en, this message translates to:
  /// **'New cycle started'**
  String get newCycleStarted;

  /// No description provided for @rewardReadyBody.
  ///
  /// In en, this message translates to:
  /// **'The stamp card is full. The reward can now be redeemed.'**
  String get rewardReadyBody;

  /// No description provided for @reviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Review details'**
  String get reviewDetails;

  /// No description provided for @operationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Completing transaction'**
  String get operationInProgress;

  /// No description provided for @noOfflineQueue.
  ///
  /// In en, this message translates to:
  /// **'No loyalty change was queued. Reconnect before continuing.'**
  String get noOfflineQueue;

  /// No description provided for @scanFrameLabel.
  ///
  /// In en, this message translates to:
  /// **'Membership QR scan frame'**
  String get scanFrameLabel;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Turn flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Turn flash off'**
  String get flashOff;

  /// No description provided for @reviewAccess.
  ///
  /// In en, this message translates to:
  /// **'Demo Access'**
  String get reviewAccess;

  /// No description provided for @reviewAccessPrompt.
  ///
  /// In en, this message translates to:
  /// **'Need sample data or app review access?'**
  String get reviewAccessPrompt;

  /// No description provided for @reviewAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Use the review access code provided with this app submission.'**
  String get reviewAccessBody;

  /// No description provided for @reviewAccessCode.
  ///
  /// In en, this message translates to:
  /// **'Review access code'**
  String get reviewAccessCode;

  /// No description provided for @reviewAccessCodeHint.
  ///
  /// In en, this message translates to:
  /// **'XXXX-XXXX'**
  String get reviewAccessCodeHint;

  /// No description provided for @backToPairing.
  ///
  /// In en, this message translates to:
  /// **'Back to device pairing'**
  String get backToPairing;

  /// No description provided for @reviewConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the review environment…'**
  String get reviewConnecting;

  /// No description provided for @reviewAccessInvalid.
  ///
  /// In en, this message translates to:
  /// **'That review code could not be accepted. Check the code and try again.'**
  String get reviewAccessInvalid;

  /// No description provided for @reviewAccessExpired.
  ///
  /// In en, this message translates to:
  /// **'This review code is no longer active. Request a current code.'**
  String get reviewAccessExpired;

  /// No description provided for @reviewAccessRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment before trying again.'**
  String get reviewAccessRateLimited;

  /// No description provided for @reviewEnvironmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The review environment is temporarily unavailable.'**
  String get reviewEnvironmentUnavailable;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoMode;

  /// No description provided for @reviewTools.
  ///
  /// In en, this message translates to:
  /// **'Demo scenarios'**
  String get reviewTools;

  /// No description provided for @reviewToolsBody.
  ///
  /// In en, this message translates to:
  /// **'These controls use fictional review data only. They cannot select a real merchant or customer.'**
  String get reviewToolsBody;

  /// No description provided for @reviewScenarios.
  ///
  /// In en, this message translates to:
  /// **'Demo scenarios'**
  String get reviewScenarios;

  /// No description provided for @reviewScenarioNew.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get reviewScenarioNew;

  /// No description provided for @reviewScenarioActive.
  ///
  /// In en, this message translates to:
  /// **'Active customer — 5 of 8'**
  String get reviewScenarioActive;

  /// No description provided for @reviewScenarioRewardReady.
  ///
  /// In en, this message translates to:
  /// **'Reward ready — 8 of 8'**
  String get reviewScenarioRewardReady;

  /// No description provided for @reviewScenarioManagerApproval.
  ///
  /// In en, this message translates to:
  /// **'Manager approval required'**
  String get reviewScenarioManagerApproval;

  /// No description provided for @reviewScenarioPurchaseThreshold.
  ///
  /// In en, this message translates to:
  /// **'Purchase threshold not met'**
  String get reviewScenarioPurchaseThreshold;

  /// No description provided for @reviewScenarioBillingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Billing blocked'**
  String get reviewScenarioBillingBlocked;

  /// No description provided for @reviewScenarioInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid customer code'**
  String get reviewScenarioInvalidQr;

  /// No description provided for @reviewInvalidQrDetail.
  ///
  /// In en, this message translates to:
  /// **'Safe invalid-code scanner state'**
  String get reviewInvalidQrDetail;

  /// No description provided for @resetReviewData.
  ///
  /// In en, this message translates to:
  /// **'Reset demo data'**
  String get resetReviewData;

  /// No description provided for @reviewResetComplete.
  ///
  /// In en, this message translates to:
  /// **'Demo data restored.'**
  String get reviewResetComplete;

  /// No description provided for @exitDemo.
  ///
  /// In en, this message translates to:
  /// **'Exit Demo'**
  String get exitDemo;

  /// No description provided for @exitDemoBody.
  ///
  /// In en, this message translates to:
  /// **'This clears the review session and returns to device pairing.'**
  String get exitDemoBody;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get initializingCamera;

  /// No description provided for @customerLoaded.
  ///
  /// In en, this message translates to:
  /// **'Customer loaded'**
  String get customerLoaded;

  /// No description provided for @expiredCustomerQr.
  ///
  /// In en, this message translates to:
  /// **'This customer code has expired'**
  String get expiredCustomerQr;

  /// No description provided for @unableToLoadCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unable to load customer'**
  String get unableToLoadCustomer;

  /// No description provided for @demoAccess.
  ///
  /// In en, this message translates to:
  /// **'Demo Access'**
  String get demoAccess;

  /// No description provided for @enterDemo.
  ///
  /// In en, this message translates to:
  /// **'Enter Demo'**
  String get enterDemo;

  /// No description provided for @sampleData.
  ///
  /// In en, this message translates to:
  /// **'Sample data'**
  String get sampleData;

  /// No description provided for @localDemoAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Explore the real Waflo Staff experience with deterministic sample customers—no merchant setup or network connection required.'**
  String get localDemoAccessBody;

  /// No description provided for @localDemoSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'This demo changes sample data on this device only. It cannot access a real merchant or customer.'**
  String get localDemoSafetyBody;

  /// No description provided for @demoScenarios.
  ///
  /// In en, this message translates to:
  /// **'Demo scenarios'**
  String get demoScenarios;

  /// No description provided for @localDemoScenarioBody.
  ///
  /// In en, this message translates to:
  /// **'Open any real Waflo screen with safe sample data, or follow the complete scan, stamp, and reward flow.'**
  String get localDemoScenarioBody;

  /// No description provided for @exitLocalDemoBody.
  ///
  /// In en, this message translates to:
  /// **'This clears the sample session and returns to device pairing. Real sessions are not affected.'**
  String get exitLocalDemoBody;

  /// No description provided for @backToDemoScenarios.
  ///
  /// In en, this message translates to:
  /// **'Back to demo scenarios'**
  String get backToDemoScenarios;

  /// No description provided for @demoControls.
  ///
  /// In en, this message translates to:
  /// **'Demo controls'**
  String get demoControls;

  /// No description provided for @simulateValidQr.
  ///
  /// In en, this message translates to:
  /// **'Simulate valid QR'**
  String get simulateValidQr;

  /// No description provided for @simulateInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'Simulate invalid QR'**
  String get simulateInvalidQr;

  /// No description provided for @simulateExpiredQr.
  ///
  /// In en, this message translates to:
  /// **'Simulate expired QR'**
  String get simulateExpiredQr;

  /// No description provided for @simulateNetworkFailure.
  ///
  /// In en, this message translates to:
  /// **'Simulate network failure'**
  String get simulateNetworkFailure;

  /// No description provided for @resetScanner.
  ///
  /// In en, this message translates to:
  /// **'Reset scanner'**
  String get resetScanner;

  /// No description provided for @simulateManagerApproved.
  ///
  /// In en, this message translates to:
  /// **'Simulate approved'**
  String get simulateManagerApproved;

  /// No description provided for @demoGroupOverview.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get demoGroupOverview;

  /// No description provided for @demoGroupScanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get demoGroupScanner;

  /// No description provided for @demoGroupCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer & loyalty'**
  String get demoGroupCustomer;

  /// No description provided for @demoGroupOperations.
  ///
  /// In en, this message translates to:
  /// **'Stamp, reward & recovery'**
  String get demoGroupOperations;

  /// No description provided for @demoGroupSystem.
  ///
  /// In en, this message translates to:
  /// **'Device & app'**
  String get demoGroupSystem;

  /// No description provided for @demoScenarioHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get demoScenarioHome;

  /// No description provided for @demoScenarioScannerReady.
  ///
  /// In en, this message translates to:
  /// **'Scanner — Ready'**
  String get demoScenarioScannerReady;

  /// No description provided for @demoScenarioScannerDetected.
  ///
  /// In en, this message translates to:
  /// **'Scanner — QR Detected'**
  String get demoScenarioScannerDetected;

  /// No description provided for @demoScenarioScannerResolving.
  ///
  /// In en, this message translates to:
  /// **'Scanner — Resolving'**
  String get demoScenarioScannerResolving;

  /// No description provided for @demoScenarioScannerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Scanner — Invalid QR'**
  String get demoScenarioScannerInvalid;

  /// No description provided for @demoScenarioScannerExpired.
  ///
  /// In en, this message translates to:
  /// **'Scanner — Expired QR'**
  String get demoScenarioScannerExpired;

  /// No description provided for @demoScenarioScannerNetwork.
  ///
  /// In en, this message translates to:
  /// **'Scanner — Network Failure'**
  String get demoScenarioScannerNetwork;

  /// No description provided for @demoScenarioScannerPermission.
  ///
  /// In en, this message translates to:
  /// **'Scanner — Permission Denied'**
  String get demoScenarioScannerPermission;

  /// No description provided for @demoScenarioCustomerZero.
  ///
  /// In en, this message translates to:
  /// **'Customer — 0 of 8'**
  String get demoScenarioCustomerZero;

  /// No description provided for @demoScenarioCustomerFive.
  ///
  /// In en, this message translates to:
  /// **'Customer — 5 of 8'**
  String get demoScenarioCustomerFive;

  /// No description provided for @demoScenarioCustomerEight.
  ///
  /// In en, this message translates to:
  /// **'Customer — 8 of 8, reward ready'**
  String get demoScenarioCustomerEight;

  /// No description provided for @demoScenarioStampConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stamp confirmation'**
  String get demoScenarioStampConfirm;

  /// No description provided for @demoScenarioStampSuccess.
  ///
  /// In en, this message translates to:
  /// **'Stamp success — 6 of 8'**
  String get demoScenarioStampSuccess;

  /// No description provided for @demoScenarioRedeemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Redeem confirmation'**
  String get demoScenarioRedeemConfirm;

  /// No description provided for @demoScenarioApprovalRequired.
  ///
  /// In en, this message translates to:
  /// **'Manager approval required'**
  String get demoScenarioApprovalRequired;

  /// No description provided for @demoScenarioApprovalPending.
  ///
  /// In en, this message translates to:
  /// **'Manager approval pending'**
  String get demoScenarioApprovalPending;

  /// No description provided for @demoScenarioApprovalRejected.
  ///
  /// In en, this message translates to:
  /// **'Manager approval rejected'**
  String get demoScenarioApprovalRejected;

  /// No description provided for @demoScenarioApprovalExpired.
  ///
  /// In en, this message translates to:
  /// **'Manager approval expired'**
  String get demoScenarioApprovalExpired;

  /// No description provided for @demoScenarioRedeemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Redeem success — reset to 0 of 8'**
  String get demoScenarioRedeemSuccess;

  /// No description provided for @demoScenarioPurchaseThreshold.
  ///
  /// In en, this message translates to:
  /// **'Purchase threshold not met'**
  String get demoScenarioPurchaseThreshold;

  /// No description provided for @demoScenarioBillingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Billing blocked'**
  String get demoScenarioBillingBlocked;

  /// No description provided for @demoScenarioSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get demoScenarioSessionExpired;

  /// No description provided for @demoScenarioDeviceRevoked.
  ///
  /// In en, this message translates to:
  /// **'Device revoked'**
  String get demoScenarioDeviceRevoked;

  /// No description provided for @demoScenarioAppLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get demoScenarioAppLock;

  /// No description provided for @demoScenarioDeviceSecurity.
  ///
  /// In en, this message translates to:
  /// **'Device & Security'**
  String get demoScenarioDeviceSecurity;

  /// No description provided for @demoScenarioSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get demoScenarioSettings;
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
      <String>['ar', 'ckb', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
