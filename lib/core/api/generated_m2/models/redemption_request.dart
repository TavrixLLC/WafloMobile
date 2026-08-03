// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'redemption_request_locale.dart';

part 'redemption_request.g.dart';

@JsonSerializable()
class RedemptionRequest {
  const RedemptionRequest({
    required this.qrPayload,
    required this.rewardEntitlementPublicId,
    this.locale,
    this.managerApprovalPublicId,
    this.note,
  });

  factory RedemptionRequest.fromJson(Map<String, Object?> json) =>
      _$RedemptionRequestFromJson(json);

  final String qrPayload;
  final RedemptionRequestLocale? locale;
  final String rewardEntitlementPublicId;
  final String? managerApprovalPublicId;
  final String? note;

  Map<String, Object?> toJson() => _$RedemptionRequestToJson(this);
}
