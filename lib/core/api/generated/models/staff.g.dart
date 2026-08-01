// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Staff _$StaffFromJson(Map<String, dynamic> json) => Staff(
  publicId: json['publicId'] as String,
  displayName: json['displayName'] as String,
  role: Role.fromJson(json['role'] as String),
);

Map<String, dynamic> _$StaffToJson(Staff instance) => <String, dynamic>{
  'publicId': instance.publicId,
  'displayName': instance.displayName,
  'role': _$RoleEnumMap[instance.role]!,
};

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.manager: 'MANAGER',
  Role.staff: 'STAFF',
  Role.$unknown: r'$unknown',
};
