// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_complete_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingCompleteContext _$PairingCompleteContextFromJson(
  Map<String, dynamic> json,
) => PairingCompleteContext(
  organizationId: json['organizationId'] as String,
  role: Role.fromJson(json['role'] as String),
  locationId: json['locationId'] as String,
);

Map<String, dynamic> _$PairingCompleteContextToJson(
  PairingCompleteContext instance,
) => <String, dynamic>{
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
