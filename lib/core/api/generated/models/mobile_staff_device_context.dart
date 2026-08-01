// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'app_policy.dart';
import 'assigned_locations.dart';
import 'current_location.dart';
import 'device2.dart';
import 'organization.dart';
import 'staff.dart';

part 'mobile_staff_device_context.g.dart';

@JsonSerializable()
class MobileStaffDeviceContext {
  const MobileStaffDeviceContext({
    required this.organization,
    required this.staff,
    required this.device,
    required this.currentLocation,
    required this.assignedLocations,
    required this.appPolicy,
    required this.requestId,
  });

  factory MobileStaffDeviceContext.fromJson(Map<String, Object?> json) =>
      _$MobileStaffDeviceContextFromJson(json);

  final Organization organization;
  final Staff staff;
  final Device2 device;
  final CurrentLocation currentLocation;
  final List<AssignedLocations> assignedLocations;
  final AppPolicy appPolicy;
  final String requestId;

  Map<String, Object?> toJson() => _$MobileStaffDeviceContextToJson(this);
}
