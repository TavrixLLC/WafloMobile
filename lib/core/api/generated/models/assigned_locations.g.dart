// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedLocations _$AssignedLocationsFromJson(Map<String, dynamic> json) =>
    AssignedLocations(
      publicId: json['publicId'] as String,
      displayName: json['displayName'] as String,
      earningAllowed: json['earningAllowed'] as bool,
      redemptionAllowed: json['redemptionAllowed'] as bool,
    );

Map<String, dynamic> _$AssignedLocationsToJson(AssignedLocations instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'displayName': instance.displayName,
      'earningAllowed': instance.earningAllowed,
      'redemptionAllowed': instance.redemptionAllowed,
    };
