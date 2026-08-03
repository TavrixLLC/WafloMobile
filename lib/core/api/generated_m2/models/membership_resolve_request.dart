// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'membership_resolve_request_locale.dart';

part 'membership_resolve_request.g.dart';

@JsonSerializable()
class MembershipResolveRequest {
  const MembershipResolveRequest({required this.qrPayload, this.locale});

  factory MembershipResolveRequest.fromJson(Map<String, Object?> json) =>
      _$MembershipResolveRequestFromJson(json);

  final String qrPayload;
  final MembershipResolveRequestLocale? locale;

  Map<String, Object?> toJson() => _$MembershipResolveRequestToJson(this);
}
