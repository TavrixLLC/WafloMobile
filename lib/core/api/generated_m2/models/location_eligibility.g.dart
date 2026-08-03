// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_eligibility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationEligibility _$LocationEligibilityFromJson(Map<String, dynamic> json) =>
    LocationEligibility(
      earning: json['earning'] as bool,
      redemption: json['redemption'] as bool,
    );

Map<String, dynamic> _$LocationEligibilityToJson(
  LocationEligibility instance,
) => <String, dynamic>{
  'earning': instance.earning,
  'redemption': instance.redemption,
};
