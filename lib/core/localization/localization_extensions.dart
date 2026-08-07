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

  String localizeMembershipStatus(String status) => switch (status) {
    'active' || 'ACTIVE' => membershipStatusActive,
    'suspended' || 'SUSPENDED' => membershipStatusSuspended,
    'expired' || 'EXPIRED' => membershipStatusExpired,
    'revoked' || 'REVOKED' => membershipStatusRevoked,
    _ => m2ContractError,
  };

  String m2ErrorMessage(String? code) => switch (code) {
    'MEMBERSHIP_CREDENTIAL_INVALID' => m2CredentialInvalid,
    'MEMBERSHIP_NOT_OPERATIONAL' ||
    'PROGRAM_NOT_OPERATIONAL' => m2MembershipBlocked,
    'PROGRAM_VERSION_MISMATCH' => m2ProgramMismatch,
    'LOCATION_NOT_AUTHORIZED' ||
    'LOCATION_EARNING_DISABLED' ||
    'LOCATION_REDEMPTION_DISABLED' ||
    'STAFF_ASSIGNMENT_REQUIRED' => m2LocationBlocked,
    'STAMP_AMOUNT_INVALID' ||
    'STAMP_OPERATION_LIMIT_EXCEEDED' => m2StampPolicyBlocked,
    'DAILY_STAMP_LIMIT_REACHED' => m2DailyLimit,
    'PURCHASE_AMOUNT_REQUIRED' ||
    'PURCHASE_AMOUNT_INVALID' ||
    'PURCHASE_AMOUNT_NEGATIVE' ||
    'PURCHASE_EXCESS_PRECISION' ||
    'PURCHASE_GROUPING_AMBIGUOUS' ||
    'TRANSACTION_REFERENCE_REQUIRED' ||
    'TRANSACTION_REFERENCE_INVALID' ||
    'TRANSACTION_REFERENCE_CARD_LIKE' => m2PurchaseRequired,
    'PURCHASE_CURRENCY_MISMATCH' ||
    'PURCHASE_CURRENCY_INVALID' => m2CurrencyMismatch,
    'PURCHASE_THRESHOLD_NOT_MET' ||
    'PURCHASE_AMOUNT_BELOW_MINIMUM' => m2PurchaseThreshold,
    'FINAL_REWARD_PENDING_REDEMPTION' => m2FinalPending,
    'REWARD_NOT_AVAILABLE' => m2RewardUnavailable,
    'REWARD_EXPIRED' => m2RewardExpired,
    'REWARD_ALREADY_REDEEMED' => m2RewardRedeemed,
    'MANAGER_APPROVAL_REQUIRED' ||
    'MANAGER_APPROVAL_INVALID' => m2ManagerApproval,
    'OPERATION_IDEMPOTENCY_CONFLICT' => m2IdempotencyConflict,
    'OPERATION_NOT_FOUND' => m2OperationNotFound,
    'OPERATION_IN_PROGRESS' => m2OperationProcessing,
    'OPERATION_FAILED' => m2OperationFailed,
    'OPERATION_BILLING_BLOCKED' => m2BillingBlocked,
    'RISK_HARD_BLOCK' => m2RiskBlocked,
    'RATE_LIMITED' => m2RateLimited,
    'OPERATION_RESULT_UNKNOWN' => m2ResultUnknown,
    'OPERATION_RECOVERY_EXPIRED' => m2RecoveryExpired,
    'BACKEND_UNAVAILABLE' => offlineOperationsBlocked,
    'STAFF_DEVICE_SIGNATURE_INVALID' ||
    'STAFF_DEVICE_BODY_DIGEST_INVALID' => signatureError,
    'STAFF_DEVICE_NONCE_REPLAYED' => nonceReplayError,
    'STAFF_DEVICE_CLOCK_SKEW' => clockSkewError,
    'DEVICE_PAIRING_INVALID' ||
    'DEVICE_PAIRING_EXPIRED' ||
    'DEVICE_PAIRING_ALREADY_USED' ||
    'DEVICE_PAIRING_ALREADY_ACTIVE' ||
    'STAFF_DEVICE_NOT_ACTIVE' ||
    'STAFF_DEVICE_NOT_FOUND' => sessionExpiredBody,
    'STAFF_DEVICE_SESSION_EXPIRED' => sessionExpiredBody,
    'STAFF_DEVICE_REVOKED' => deviceRevokedBody,
    'STAFF_DEVICE_COMPROMISED' => deviceCompromisedBody,
    'APP_UPDATE_REQUIRED' ||
    'STAFF_APP_VERSION_UNSUPPORTED' => updateRequiredBody,
    'VALIDATION_FAILED' => validationError,
    'INVALID_RESPONSE_BODY' => m2ContractError,
    _ => genericError,
  };
}
