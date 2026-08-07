// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeem_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedeemRequest _$RedeemRequestFromJson(Map<String, dynamic> json) =>
    RedeemRequest(
      qrPayload: json['qrPayload'] as String,
      rewardEntitlementPublicId: json['rewardEntitlementPublicId'] as String,
      managerApprovalPublicId: json['managerApprovalPublicId'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$RedeemRequestToJson(RedeemRequest instance) =>
    <String, dynamic>{
      'qrPayload': instance.qrPayload,
      'rewardEntitlementPublicId': instance.rewardEntitlementPublicId,
      'managerApprovalPublicId': instance.managerApprovalPublicId,
      'note': instance.note,
    };
