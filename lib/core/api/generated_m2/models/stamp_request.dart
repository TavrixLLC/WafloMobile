// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'manager_override.dart';
import 'stamp_request_locale.dart';

part 'stamp_request.g.dart';

@JsonSerializable()
class StampRequest {
  const StampRequest({
    required this.qrPayload,
    required this.amount,
    this.locale,
    this.purchaseAmountMinor,
    this.purchaseCurrency,
    this.merchantTransactionReference,
    this.managerOverride,
    this.clientObservedAt,
  });

  factory StampRequest.fromJson(Map<String, Object?> json) =>
      _$StampRequestFromJson(json);

  final String qrPayload;
  final StampRequestLocale? locale;
  final int amount;
  final int? purchaseAmountMinor;
  final dynamic purchaseCurrency;
  final String? merchantTransactionReference;
  final ManagerOverride? managerOverride;
  final DateTime? clientObservedAt;

  Map<String, Object?> toJson() => _$StampRequestToJson(this);
}
