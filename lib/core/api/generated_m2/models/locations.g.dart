// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
  locationId: json['locationId'] as String,
  earningAllowed: json['earningAllowed'] as bool,
  redemptionAllowed: json['redemptionAllowed'] as bool,
);

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
  'locationId': instance.locationId,
  'earningAllowed': instance.earningAllowed,
  'redemptionAllowed': instance.redemptionAllowed,
};
