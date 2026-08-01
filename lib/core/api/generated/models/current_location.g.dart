// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentLocation _$CurrentLocationFromJson(Map<String, dynamic> json) =>
    CurrentLocation(
      publicId: json['publicId'] as String,
      displayName: json['displayName'] as String,
      earningAllowed: json['earningAllowed'] as bool,
      redemptionAllowed: json['redemptionAllowed'] as bool,
    );

Map<String, dynamic> _$CurrentLocationToJson(CurrentLocation instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'displayName': instance.displayName,
      'earningAllowed': instance.earningAllowed,
      'redemptionAllowed': instance.redemptionAllowed,
    };
