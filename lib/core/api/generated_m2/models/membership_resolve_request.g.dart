// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_resolve_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipResolveRequest _$MembershipResolveRequestFromJson(
  Map<String, dynamic> json,
) => MembershipResolveRequest(
  qrPayload: json['qrPayload'] as String,
  locale: json['locale'] == null
      ? null
      : MembershipResolveRequestLocale.fromJson(json['locale'] as String),
);

Map<String, dynamic> _$MembershipResolveRequestToJson(
  MembershipResolveRequest instance,
) => <String, dynamic>{
  'qrPayload': instance.qrPayload,
  'locale': _$MembershipResolveRequestLocaleEnumMap[instance.locale],
};

const _$MembershipResolveRequestLocaleEnumMap = {
  MembershipResolveRequestLocale.en: 'en',
  MembershipResolveRequestLocale.ar: 'ar',
  MembershipResolveRequestLocale.$unknown: r'$unknown',
};
