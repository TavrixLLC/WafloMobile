// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'filled.dart';
import 'empty.dart';

part 'stamp_visuals.g.dart';

@JsonSerializable()
class StampVisuals {
  const StampVisuals({required this.filled, required this.empty});

  factory StampVisuals.fromJson(Map<String, Object?> json) =>
      _$StampVisualsFromJson(json);

  final Filled filled;
  final Empty empty;

  Map<String, Object?> toJson() => _$StampVisualsToJson(this);
}
