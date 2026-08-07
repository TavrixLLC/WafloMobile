// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'redeem_request.g.dart';

@JsonSerializable()
class RedeemRequest {
  const RedeemRequest({
    required this.qrPayload,
    required this.rewardEntitlementPublicId,
    this.managerApprovalPublicId,
    this.note,
  });

  factory RedeemRequest.fromJson(Map<String, Object?> json) =>
      _$RedeemRequestFromJson(json);

  final String qrPayload;
  final String rewardEntitlementPublicId;
  final String? managerApprovalPublicId;
  final String? note;

  Map<String, Object?> toJson() => _$RedeemRequestToJson(this);
}
