// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppPolicy _$AppPolicyFromJson(Map<String, dynamic> json) => AppPolicy(
  minimumSupportedVersion: json['minimumSupportedVersion'] as String,
  updateRequired: json['updateRequired'] as bool,
);

Map<String, dynamic> _$AppPolicyToJson(AppPolicy instance) => <String, dynamic>{
  'minimumSupportedVersion': instance.minimumSupportedVersion,
  'updateRequired': instance.updateRequired,
};
