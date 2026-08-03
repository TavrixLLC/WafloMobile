// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemption_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedemptionRequest _$RedemptionRequestFromJson(Map<String, dynamic> json) =>
    RedemptionRequest(
      qrPayload: json['qrPayload'] as String,
      rewardEntitlementPublicId: json['rewardEntitlementPublicId'] as String,
      locale: json['locale'] == null
          ? null
          : RedemptionRequestLocale.fromJson(json['locale'] as String),
      managerApprovalPublicId: json['managerApprovalPublicId'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$RedemptionRequestToJson(RedemptionRequest instance) =>
    <String, dynamic>{
      'qrPayload': instance.qrPayload,
      'locale': _$RedemptionRequestLocaleEnumMap[instance.locale],
      'rewardEntitlementPublicId': instance.rewardEntitlementPublicId,
      'managerApprovalPublicId': instance.managerApprovalPublicId,
      'note': instance.note,
    };

const _$RedemptionRequestLocaleEnumMap = {
  RedemptionRequestLocale.en: 'en',
  RedemptionRequestLocale.ar: 'ar',
  RedemptionRequestLocale.$unknown: r'$unknown',
};
