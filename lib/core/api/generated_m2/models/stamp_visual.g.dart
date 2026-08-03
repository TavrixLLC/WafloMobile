// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stamp_visual.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StampVisual _$StampVisualFromJson(Map<String, dynamic> json) => StampVisual(
  states: (json['states'] as List<dynamic>)
      .map((e) => States.fromJson(e as String))
      .toList(),
  filledAssetUrl: json['filledAssetUrl'] as String,
  emptyAssetUrl: json['emptyAssetUrl'] as String,
  filledAssetDigest: json['filledAssetDigest'] as String,
  emptyAssetDigest: json['emptyAssetDigest'] as String,
  accessibleLabel: json['accessibleLabel'] as String,
  backgroundColor: json['backgroundColor'] as String,
  foregroundColor: json['foregroundColor'] as String,
);

Map<String, dynamic> _$StampVisualToJson(StampVisual instance) =>
    <String, dynamic>{
      'states': instance.states.map((e) => _$StatesEnumMap[e]!).toList(),
      'filledAssetUrl': instance.filledAssetUrl,
      'emptyAssetUrl': instance.emptyAssetUrl,
      'filledAssetDigest': instance.filledAssetDigest,
      'emptyAssetDigest': instance.emptyAssetDigest,
      'accessibleLabel': instance.accessibleLabel,
      'backgroundColor': instance.backgroundColor,
      'foregroundColor': instance.foregroundColor,
    };

const _$StatesEnumMap = {
  States.filled: 'FILLED',
  States.empty: 'EMPTY',
  States.$unknown: r'$unknown',
};
