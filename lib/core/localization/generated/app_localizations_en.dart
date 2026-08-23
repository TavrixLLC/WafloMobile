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
  String get kurdishGroup => 'کوردی';

  @override
  String get kurdishBadini => 'بادینی';

  @override
  String get kurdishSorani => 'سۆرانی';

  @override
  String get cameraTitle => 'Camera access for pairing';

  @override
  String get cameraBody =>
      'Waflo Staff uses the camera to scan staff pairing codes and customer membership codes.';

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
  String get pairingRecovering => 'Recovering the secure pairing challenge';

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
  String get organizationLabel => 'Organization';

  @override
  String get staffLabel => 'Staff member';

  @override
  String get deviceStatusLabel => 'Device status';

  @override
  String get currentLocationLabel => 'Current location';

  @override
  String get locationsTitle => 'Assigned locations';

  @override
  String get earningCapability => 'Earning';

  @override
  String get redemptionCapability => 'Redemption';

  @override
  String get capabilityAllowed => 'Allowed';

  @override
  String get capabilityBlocked => 'Not allowed';

  @override
  String get updatePolicyLabel => 'Update policy';

  @override
  String minimumSupportedVersion(Object version) {
    return 'Minimum supported version: $version';
  }

  @override
  String get appVersionCurrent => 'This app version is supported';

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
  String get homeHeaderTitle => 'Every visit counts';

  @override
  String get homeHeaderSubtitle =>
      'Scan the customer and let Waflo handle the rest.';

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
  String get themeSystem => 'System';

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
  String get staffUserDeactivatedTitle => 'Staff access deactivated';

  @override
  String get staffUserDeactivatedBody =>
      'This Staff identity is no longer active. Ask an Owner to restore access, then pair this phone again.';

  @override
  String get staffMembershipInactiveTitle => 'Staff membership inactive';

  @override
  String get staffMembershipInactiveBody =>
      'Access to this merchant is no longer active. Contact an Owner or Manager, then pair this phone again.';

  @override
  String get staffLocationInvalidTitle => 'Location access removed';

  @override
  String get staffLocationInvalidBody =>
      'This phone is no longer assigned to its paired location. Ask an Owner or Manager to assign and pair it again.';

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
  String get pairDeviceAgain => 'Pair device again';

  @override
  String get genericError => 'Something went wrong. Try again safely.';

  @override
  String get operationNotCompleted => 'Operation not completed';

  @override
  String get customerOperationsPaused => 'Customer operations are paused';

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

  @override
  String get m2ScannerTitle => 'Scan customer';

  @override
  String get m2ScannerInstructions =>
      'Place the customer Waflo membership QR inside the frame. The code is not displayed or saved.';

  @override
  String get resolvingMembership => 'Resolving membership securely';

  @override
  String get membershipTitle => 'Membership';

  @override
  String get customerLabel => 'Customer';

  @override
  String get programLabel => 'Program';

  @override
  String get membershipStatusLabel => 'Membership status';

  @override
  String get membershipStatusActive => 'Active';

  @override
  String get membershipStatusSuspended => 'Suspended';

  @override
  String get membershipStatusExpired => 'Expired';

  @override
  String get membershipStatusRevoked => 'Revoked';

  @override
  String progressOf(Object goal, Object progress) {
    return '$progress of $goal stamps';
  }

  @override
  String completedCycles(Object count) {
    return 'Completed cycles: $count';
  }

  @override
  String resolvedAt(Object time) {
    return 'Resolved $time';
  }

  @override
  String get rewardReady => 'Final reward ready';

  @override
  String get earningAvailable => 'Earning is available here';

  @override
  String get redemptionAvailable => 'Redemption is available here';

  @override
  String get stampAmount => 'Stamp amount';

  @override
  String projectedProgress(Object goal, Object progress) {
    return 'After approval: $progress of $goal';
  }

  @override
  String get purchaseAmount => 'Purchase amount';

  @override
  String requiredCurrency(Object currency) {
    return 'Required currency: $currency';
  }

  @override
  String purchaseMinimum(Object amount) {
    return 'Minimum purchase: $amount';
  }

  @override
  String get transactionReference => 'Transaction reference';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get continueToReview => 'Review operation';

  @override
  String get reviewStampTitle => 'Review stamps';

  @override
  String get confirmStamp => 'Add stamps';

  @override
  String get issuingStamps => 'Adding stamps securely';

  @override
  String get stampSuccessTitle => 'Stamps added';

  @override
  String stampsIssued(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stamps added',
      one: '1 stamp added',
    );
    return '$_temp0';
  }

  @override
  String get rewardUnlocked => 'Reward unlocked';

  @override
  String get scanNextCustomer => 'Scan next customer';

  @override
  String get rewardsTitle => 'Available rewards';

  @override
  String get milestoneReward => 'Milestone reward';

  @override
  String get finalReward => 'Final reward';

  @override
  String thresholdLabel(Object count) {
    return 'Threshold: $count stamps';
  }

  @override
  String expirationLabel(Object date) {
    return 'Expires $date';
  }

  @override
  String redemptionCount(Object count, Object maximum) {
    return 'Redeemed $count of $maximum';
  }

  @override
  String get managerApprovalRequired => 'Manager approval required';

  @override
  String get managerApprovalBody =>
      'Ask an Owner or Manager to approve this exact reward in Merchant Web. Keep this transaction open, then check again here.';

  @override
  String get managerApprovalPending => 'Waiting for manager approval';

  @override
  String get managerApprovalPendingBody =>
      'No reward has been redeemed yet. The original request is held safely while an Owner or Manager decides in Merchant Web.';

  @override
  String get managerApprovalChecking => 'Checking approval';

  @override
  String get managerApprovalCheckingBody =>
      'Waflo is checking the original reward request. Do not start another redemption.';

  @override
  String get managerApprovalCheck => 'Check approval';

  @override
  String get approvalStepRequested => 'Staff requested';

  @override
  String get approvalStepMerchant => 'Manager decides on Web';

  @override
  String get approvalStepComplete => 'Staff completes here';

  @override
  String get managerApprovalRejectedTitle => 'Approval declined';

  @override
  String get managerApprovalRejectedBody =>
      'The reward was not redeemed. Start a new deliberate redemption only if the customer still wants to continue.';

  @override
  String get managerApprovalExpiredTitle => 'Approval expired';

  @override
  String get managerApprovalExpiredBody =>
      'This approval can no longer be used. Start a new redemption to request a fresh decision.';

  @override
  String get managerApprovalConsumedTitle => 'Approval already used';

  @override
  String get managerApprovalConsumedBody =>
      'Waflo will use the latest customer state. Do not reuse this approval for another transaction.';

  @override
  String get managerApprovalInvalidTitle => 'Approval cannot be used';

  @override
  String get managerApprovalInvalidBody =>
      'The approval does not match this secure reward request. No loyalty change was made; refresh the customer state or contact an Owner.';

  @override
  String get managerApprovalStaleTitle => 'Reward details changed';

  @override
  String get managerApprovalStaleBody =>
      'The reward changed after approval was requested. No redemption was made; scan the customer again.';

  @override
  String get managerApproverInactiveTitle => 'Manager access changed';

  @override
  String get managerApproverInactiveBody =>
      'The approving Manager no longer has permission. No redemption was made; contact an active Owner or Manager.';

  @override
  String get approvalNoMutation =>
      'Customer loyalty remains unchanged until Waflo confirms redemption.';

  @override
  String get startNewRedemption => 'Start new redemption';

  @override
  String get refreshCustomerState => 'Scan customer again';

  @override
  String get redeem => 'Redeem reward';

  @override
  String get redemptionReviewTitle => 'Review reward redemption';

  @override
  String finalResetWarning(Object goal) {
    return 'After redemption, this cycle will complete and the stamp card will reset to 0 of $goal.';
  }

  @override
  String get confirmRedemption => 'Confirm redemption';

  @override
  String get redeemingReward => 'Redeeming reward securely';

  @override
  String get redemptionSuccessTitle => 'Reward redeemed';

  @override
  String get progressUnchanged => 'Stamp progress is unchanged.';

  @override
  String cycleResetComplete(Object goal) {
    return 'Cycle completed. Progress reset to 0 of $goal.';
  }

  @override
  String get pendingOperationTitle => 'Operation result pending';

  @override
  String get pendingOperationBody =>
      'Do not start a new operation. Check the original command result when the connection is available.';

  @override
  String get checkStatus => 'Check result';

  @override
  String get dismissRecovery => 'Return home';

  @override
  String get rescanRequired =>
      'Scan the customer membership again before retrying the same command.';

  @override
  String get offlineOperationsBlocked =>
      'Loyalty operations require an online connection.';

  @override
  String get noCapabilitiesBody =>
      'This location permits neither earning nor redemption. Refresh the device context or contact a Manager.';

  @override
  String get notAvailableInM2 => 'Not available in M2';

  @override
  String get refreshRequired => 'Refresh context';

  @override
  String operationReferenceSuffix(Object suffix) {
    return 'Operation reference ending $suffix';
  }

  @override
  String get done => 'Done';

  @override
  String get finalReady =>
      'All stamps are filled. Redeem the final reward before earning more.';

  @override
  String get m2CredentialInvalid =>
      'This membership code is invalid. Ask the customer to show a fresh code.';

  @override
  String get m2MembershipBlocked =>
      'This membership or program is not available for loyalty operations.';

  @override
  String get m2ProgramMismatch =>
      'The program changed. Scan the membership again.';

  @override
  String get m2LocationBlocked =>
      'This operation is not authorized at the current location.';

  @override
  String get m2StampPolicyBlocked =>
      'The selected stamp amount is not permitted.';

  @override
  String get m2DailyLimit => 'The daily stamp allowance has been reached.';

  @override
  String get m2PurchaseRequired => 'Enter the required purchase amount.';

  @override
  String get m2CurrencyMismatch =>
      'Use the exact currency required by the program.';

  @override
  String get m2PurchaseThreshold =>
      'The purchase amount does not meet the required minimum.';

  @override
  String get m2FinalPending =>
      'Redeem the final reward before issuing more stamps.';

  @override
  String get m2RewardUnavailable => 'This reward is no longer available.';

  @override
  String get m2RewardExpired => 'This reward has expired.';

  @override
  String get m2RewardRedeemed => 'This reward was already redeemed.';

  @override
  String get m2ManagerApproval =>
      'An approved Manager flow is required. This app will not bypass it.';

  @override
  String get m2IdempotencyConflict =>
      'The original operation details do not match this command. Contact support.';

  @override
  String get m2OperationNotFound => 'The original command was not found.';

  @override
  String get m2OperationProcessing =>
      'The original operation is still processing.';

  @override
  String get m2OperationFailed =>
      'The original operation failed and no success was recorded.';

  @override
  String get m2BillingBlocked =>
      'Loyalty operations are paused for this merchant. No customer progress changed. Ask an Owner to review billing in Merchant Web.';

  @override
  String get pairingInternalFailure =>
      'Pairing could not be completed safely. Try a fresh pairing code or ask an Owner for help.';

  @override
  String get m2RiskBlocked =>
      'Waflo blocked this operation for security review.';

  @override
  String get m2RateLimited =>
      'Too many requests. Wait briefly, then check again.';

  @override
  String get m2ContractError =>
      'Waflo returned an unsafe or incompatible response. Operations are disabled.';

  @override
  String get m2RecoveryExpired =>
      'This pending result needs Waflo support before another operation is attempted.';

  @override
  String get m2ResultUnknown =>
      'The server result is unknown. Do not repeat the operation; check its status.';

  @override
  String get ready => 'Ready';

  @override
  String get offline => 'Offline';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get scanCustomerHelp =>
      'Hold the customer’s membership code inside the frame.';

  @override
  String get scannerBlockedPending =>
      'Resolve the pending transaction before scanning again.';

  @override
  String get checkingTransaction => 'Checking transaction status';

  @override
  String get pendingDoNotScanAgain => 'Do not scan this customer again yet.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get connectionInterruptedAfterSend =>
      'The connection was interrupted after the request may have been sent. Waflo will check the original transaction only.';

  @override
  String get requestingCamera => 'Requesting camera access';

  @override
  String get cameraPermissionRequiredTitle => 'Camera access needed';

  @override
  String get cameraPermissionRequiredBody =>
      'Allow camera access to scan the customer’s membership code.';

  @override
  String get cameraPermissionDeniedTitle => 'Camera access is off';

  @override
  String get cameraPermissionDeniedBody =>
      'Open device settings and allow camera access for Waflo Staff.';

  @override
  String get scannerReady => 'Ready to scan';

  @override
  String get codeDetected => 'Code detected';

  @override
  String get scannerResolving => 'Loading customer…';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get networkUnavailable => 'Network unavailable';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get scannerPaused =>
      'Scanner paused while Waflo Staff is in the background';

  @override
  String get invalidCustomerQr => 'This is not a valid Waflo membership code.';

  @override
  String get unsupportedCustomerQr =>
      'This membership code is not supported by this version of Waflo Staff.';

  @override
  String get membershipNotFound => 'Membership not found';

  @override
  String get membershipInactive => 'This membership is not active.';

  @override
  String get locationNotEligible =>
      'This location cannot serve this membership.';

  @override
  String get currentProgress => 'Current progress';

  @override
  String get rewardUnlockNotice => 'Reward unlock';

  @override
  String stampsUntilReward(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stamps until reward',
      one: '1 stamp until reward',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyProgressUpdated => 'Loyalty progress updated';

  @override
  String get rapidScanMode => 'Rapid scan mode';

  @override
  String get rapidScanModeBody =>
      'Keep Scan next customer as the main action after success.';

  @override
  String get rapidScanReady =>
      'Customer details and purchase inputs are cleared before the scanner opens.';

  @override
  String get deviceAndSecurity => 'Device & Security';

  @override
  String get deviceControls => 'Device controls';

  @override
  String get securityProtected => 'Security: Protected';

  @override
  String get securityProtectedBody =>
      'Device status and local privacy controls are active.';

  @override
  String get thisDevice => 'This device';

  @override
  String get deviceName => 'Device name';

  @override
  String get activeOrganization => 'Active organization';

  @override
  String get lastVerified => 'Last verified';

  @override
  String get appVersionLabel => 'App version';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get appLockSettings => 'App lock settings';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockLocalOnly =>
      'App lock protects this phone only. It does not change your Waflo role or server permissions.';

  @override
  String get appLockOff => 'Off';

  @override
  String get biometric => 'Biometric';

  @override
  String get pinAndBiometrics => 'PIN + biometrics';

  @override
  String get localStaffPin => 'Local Staff PIN';

  @override
  String get lockAfter => 'Lock after';

  @override
  String get lockImmediately => 'Immediately';

  @override
  String get afterOneMinute => 'After 1 minute';

  @override
  String get afterFiveMinutes => 'After 5 minutes';

  @override
  String get createLocalStaffPin => 'Create Local Staff PIN';

  @override
  String get pinNeverManager =>
      'Use 4–6 digits. This unlocks this phone only and is never a Manager PIN.';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get savePin => 'Save PIN';

  @override
  String get pinMismatch => 'The PIN entries do not match.';

  @override
  String get pinLengthHelp => 'Enter 4–6 digits.';

  @override
  String get appLocked => 'Waflo Staff is locked';

  @override
  String get appLockedBody =>
      'Unlock to continue. Your signed-in session and any pending transaction remain safely preserved.';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockWithBiometrics => 'Unlock with biometrics';

  @override
  String get biometricUnlockReason => 'Unlock Waflo Staff';

  @override
  String get biometricSetupReason =>
      'Confirm biometrics to enable local app lock';

  @override
  String get biometricUnavailable =>
      'Biometric unlock is not available on this phone.';

  @override
  String get createPinFirst => 'Create a PIN before enabling biometrics.';

  @override
  String get enterPinToUnlock => 'Enter your PIN';

  @override
  String get pinUnlockBody => 'Use the local Staff PIN created on this phone.';

  @override
  String get biometricPinFallback =>
      'Biometrics weren’t confirmed. Enter your PIN to continue.';

  @override
  String get tryBiometricsAgain => 'Try biometrics again';

  @override
  String get pinRateLimited => 'Too many attempts. Wait before trying again.';

  @override
  String get unlockFailed => 'Waflo Staff could not be unlocked. Try again.';

  @override
  String get devicePendingTitle => 'Device approval pending';

  @override
  String get devicePendingBody =>
      'This phone is paired, but it is not ready for customer operations yet.';

  @override
  String deviceReadyAtLocation(Object location) {
    return 'Ready at $location';
  }

  @override
  String get serveNextCustomer => 'Serve the next customer';

  @override
  String get appInformation => 'App information';

  @override
  String get appearanceAndLanguage => 'Appearance & language';

  @override
  String get customerDetailsCleared => 'Customer details cleared';

  @override
  String get newCycleStarted => 'New cycle started';

  @override
  String get rewardReadyBody =>
      'The stamp card is full. The reward can now be redeemed.';

  @override
  String get reviewDetails => 'Review details';

  @override
  String get operationInProgress => 'Completing transaction';

  @override
  String get noOfflineQueue =>
      'No loyalty change was queued. Reconnect before continuing.';

  @override
  String get scanFrameLabel => 'Membership QR scan frame';

  @override
  String get flashOn => 'Turn flash on';

  @override
  String get flashOff => 'Turn flash off';

  @override
  String get reviewAccess => 'Demo Access';

  @override
  String get reviewAccessPrompt => 'Need sample data or app review access?';

  @override
  String get reviewAccessBody =>
      'Use the review access code provided with this app submission.';

  @override
  String get reviewAccessCode => 'Review access code';

  @override
  String get reviewAccessCodeHint => 'XXXX-XXXX';

  @override
  String get backToPairing => 'Back to device pairing';

  @override
  String get reviewConnecting => 'Connecting to the review environment…';

  @override
  String get reviewAccessInvalid =>
      'That review code could not be accepted. Check the code and try again.';

  @override
  String get reviewAccessExpired =>
      'This review code is no longer active. Request a current code.';

  @override
  String get reviewAccessRateLimited =>
      'Too many attempts. Wait a moment before trying again.';

  @override
  String get reviewEnvironmentUnavailable =>
      'The review environment is temporarily unavailable.';

  @override
  String get demoMode => 'Demo mode';

  @override
  String get reviewTools => 'Demo scenarios';

  @override
  String get reviewToolsBody =>
      'These controls use fictional review data only. They cannot select a real merchant or customer.';

  @override
  String get reviewScenarios => 'Demo scenarios';

  @override
  String get reviewScenarioNew => 'New customer';

  @override
  String get reviewScenarioActive => 'Active customer — 5 of 8';

  @override
  String get reviewScenarioRewardReady => 'Reward ready — 8 of 8';

  @override
  String get reviewScenarioManagerApproval => 'Manager approval required';

  @override
  String get reviewScenarioPurchaseThreshold => 'Purchase threshold not met';

  @override
  String get reviewScenarioBillingBlocked => 'Billing blocked';

  @override
  String get reviewScenarioInvalidQr => 'Invalid customer code';

  @override
  String get reviewInvalidQrDetail => 'Safe invalid-code scanner state';

  @override
  String get resetReviewData => 'Reset demo data';

  @override
  String get reviewResetComplete => 'Demo data restored.';

  @override
  String get exitDemo => 'Exit Demo';

  @override
  String get exitDemoBody =>
      'This clears the review session and returns to device pairing.';

  @override
  String get initializingCamera => 'Starting camera…';

  @override
  String get customerLoaded => 'Customer loaded';

  @override
  String get expiredCustomerQr => 'This customer code has expired';

  @override
  String get unableToLoadCustomer => 'Unable to load customer';

  @override
  String get demoAccess => 'Demo Access';

  @override
  String get enterDemo => 'Enter Demo';

  @override
  String get sampleData => 'Sample data';

  @override
  String get localDemoAccessBody =>
      'Explore the real Waflo Staff experience with deterministic sample customers—no merchant setup or network connection required.';

  @override
  String get localDemoSafetyBody =>
      'This demo changes sample data on this device only. It cannot access a real merchant or customer.';

  @override
  String get demoScenarios => 'Demo scenarios';

  @override
  String get localDemoScenarioBody =>
      'Open any real Waflo screen with safe sample data, or follow the complete scan, stamp, and reward flow.';

  @override
  String get exitLocalDemoBody =>
      'This clears the sample session and returns to device pairing. Real sessions are not affected.';

  @override
  String get backToDemoScenarios => 'Back to demo scenarios';

  @override
  String get demoControls => 'Demo controls';

  @override
  String get simulateValidQr => 'Simulate valid QR';

  @override
  String get simulateInvalidQr => 'Simulate invalid QR';

  @override
  String get simulateExpiredQr => 'Simulate expired QR';

  @override
  String get simulateNetworkFailure => 'Simulate network failure';

  @override
  String get resetScanner => 'Reset scanner';

  @override
  String get simulateManagerApproved => 'Simulate approved';

  @override
  String get demoGroupOverview => 'Start';

  @override
  String get demoGroupScanner => 'Scanner';

  @override
  String get demoGroupCustomer => 'Customer & loyalty';

  @override
  String get demoGroupOperations => 'Stamp, reward & recovery';

  @override
  String get demoGroupSystem => 'Device & app';

  @override
  String get demoScenarioHome => 'Home';

  @override
  String get demoScenarioScannerReady => 'Scanner — Ready';

  @override
  String get demoScenarioScannerDetected => 'Scanner — QR Detected';

  @override
  String get demoScenarioScannerResolving => 'Scanner — Resolving';

  @override
  String get demoScenarioScannerInvalid => 'Scanner — Invalid QR';

  @override
  String get demoScenarioScannerExpired => 'Scanner — Expired QR';

  @override
  String get demoScenarioScannerNetwork => 'Scanner — Network Failure';

  @override
  String get demoScenarioScannerPermission => 'Scanner — Permission Denied';

  @override
  String get demoScenarioCustomerZero => 'Customer — 0 of 8';

  @override
  String get demoScenarioCustomerFive => 'Customer — 5 of 8';

  @override
  String get demoScenarioCustomerEight => 'Customer — 8 of 8, reward ready';

  @override
  String get demoScenarioStampConfirm => 'Stamp confirmation';

  @override
  String get demoScenarioStampSuccess => 'Stamp success — 6 of 8';

  @override
  String get demoScenarioRedeemConfirm => 'Redeem confirmation';

  @override
  String get demoScenarioApprovalRequired => 'Manager approval required';

  @override
  String get demoScenarioApprovalPending => 'Manager approval pending';

  @override
  String get demoScenarioApprovalRejected => 'Manager approval rejected';

  @override
  String get demoScenarioApprovalExpired => 'Manager approval expired';

  @override
  String get demoScenarioRedeemSuccess => 'Redeem success — reset to 0 of 8';

  @override
  String get demoScenarioPurchaseThreshold => 'Purchase threshold not met';

  @override
  String get demoScenarioBillingBlocked => 'Billing blocked';

  @override
  String get demoScenarioSessionExpired => 'Session expired';

  @override
  String get demoScenarioDeviceRevoked => 'Device revoked';

  @override
  String get demoScenarioAppLock => 'App Lock';

  @override
  String get demoScenarioDeviceSecurity => 'Device & Security';

  @override
  String get demoScenarioSettings => 'Settings';
}
