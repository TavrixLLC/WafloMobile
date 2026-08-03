// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'states.dart';

part 'stamp_visual.g.dart';

@JsonSerializable()
class StampVisual {
  const StampVisual({
    required this.states,
    required this.filledAssetUrl,
    required this.emptyAssetUrl,
    required this.filledAssetDigest,
    required this.emptyAssetDigest,
    required this.accessibleLabel,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  factory StampVisual.fromJson(Map<String, Object?> json) =>
      _$StampVisualFromJson(json);

  final List<States> states;
  final String filledAssetUrl;
  final String emptyAssetUrl;
  final String filledAssetDigest;
  final String emptyAssetDigest;
  final String accessibleLabel;
  final String backgroundColor;
  final String foregroundColor;

  Map<String, Object?> toJson() => _$StampVisualToJson(this);
}
