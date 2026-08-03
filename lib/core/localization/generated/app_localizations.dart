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

  /// No description provided for @m2ScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan customer membership'**
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
  /// **'Review stamp issuance'**
  String get reviewStampTitle;

  /// No description provided for @confirmStamp.
  ///
  /// In en, this message translates to:
  /// **'Confirm stamp issuance'**
  String get confirmStamp;

  /// No description provided for @issuingStamps.
  ///
  /// In en, this message translates to:
  /// **'Issuing stamps securely'**
  String get issuingStamps;

  /// No description provided for @stampSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Stamps issued'**
  String get stampSuccessTitle;

  /// No description provided for @stampsIssued.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stamp issued} other{{count} stamps issued}}'**
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
  /// **'This reward cannot be redeemed in M2. Use an approved Manager flow when it becomes available.'**
  String get managerApprovalBody;

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
  /// **'Loyalty operations are unavailable for this organization.'**
  String get m2BillingBlocked;

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
