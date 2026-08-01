// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Context _$ContextFromJson(Map<String, dynamic> json) => Context(
  organizationId: json['organizationId'] as String,
  role: Role.fromJson(json['role'] as String),
  locationId: json['locationId'] as String,
);

Map<String, dynamic> _$ContextToJson(Context instance) => <String, dynamic>{
  'organizationId': instance.organizationId,
  'role': _$RoleEnumMap[instance.role]!,
  'locationId': instance.locationId,
};

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.manager: 'MANAGER',
  Role.staff: 'STAFF',
  Role.$unknown: r'$unknown',
};
