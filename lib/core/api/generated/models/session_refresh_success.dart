// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'session_refresh_data.dart';

part 'session_refresh_success.g.dart';

@JsonSerializable()
class SessionRefreshSuccess {
  const SessionRefreshSuccess({required this.data, required this.requestId});

  factory SessionRefreshSuccess.fromJson(Map<String, Object?> json) =>
      _$SessionRefreshSuccessFromJson(json);

  final SessionRefreshData data;
  final String requestId;

  Map<String, Object?> toJson() => _$SessionRefreshSuccessToJson(this);
}
