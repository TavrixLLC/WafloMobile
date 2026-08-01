// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role.dart';
import 'uuid.dart';

part 'pairing_complete_context.g.dart';

@JsonSerializable()
class PairingCompleteContext {
  const PairingCompleteContext({
    required this.organizationId,
    required this.role,
    required this.locationId,
  });

  factory PairingCompleteContext.fromJson(Map<String, Object?> json) =>
      _$PairingCompleteContextFromJson(json);

  final Uuid organizationId;
  final Role role;
  final Uuid locationId;

  Map<String, Object?> toJson() => _$PairingCompleteContextToJson(this);
}
