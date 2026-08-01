// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_staff_device_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MobileStaffDeviceContext _$MobileStaffDeviceContextFromJson(
  Map<String, dynamic> json,
) => MobileStaffDeviceContext(
  organization: Organization.fromJson(
    json['organization'] as Map<String, dynamic>,
  ),
  staff: Staff.fromJson(json['staff'] as Map<String, dynamic>),
  device: Device2.fromJson(json['device'] as Map<String, dynamic>),
  currentLocation: CurrentLocation.fromJson(
    json['currentLocation'] as Map<String, dynamic>,
  ),
  assignedLocations: (json['assignedLocations'] as List<dynamic>)
      .map((e) => AssignedLocations.fromJson(e as Map<String, dynamic>))
      .toList(),
  appPolicy: AppPolicy.fromJson(json['appPolicy'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$MobileStaffDeviceContextToJson(
  MobileStaffDeviceContext instance,
) => <String, dynamic>{
  'organization': instance.organization,
  'staff': instance.staff,
  'device': instance.device,
  'currentLocation': instance.currentLocation,
  'assignedLocations': instance.assignedLocations,
  'appPolicy': instance.appPolicy,
  'requestId': instance.requestId,
};
