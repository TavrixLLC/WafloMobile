// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum OperationPublicStatusResultOperationType {
  @JsonValue('ISSUE_STAMP')
  issueStamp('ISSUE_STAMP'),
  @JsonValue('REDEEM_REWARD')
  redeemReward('REDEEM_REWARD'),
  @JsonValue('REVERSE_STAMP')
  reverseStamp('REVERSE_STAMP'),
  @JsonValue('REVERSE_REDEMPTION')
  reverseRedemption('REVERSE_REDEMPTION'),
  @JsonValue('MANUAL_ADJUSTMENT')
  manualAdjustment('MANUAL_ADJUSTMENT'),
  @JsonValue('SUSPEND_MEMBERSHIP')
  suspendMembership('SUSPEND_MEMBERSHIP'),
  @JsonValue('RESTORE_MEMBERSHIP')
  restoreMembership('RESTORE_MEMBERSHIP'),
  @JsonValue('REVOKE_MEMBERSHIP')
  revokeMembership('REVOKE_MEMBERSHIP'),
  @JsonValue('EXPIRE_REWARD')
  expireReward('EXPIRE_REWARD'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const OperationPublicStatusResultOperationType(this.json);

  factory OperationPublicStatusResultOperationType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<OperationPublicStatusResultOperationType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
