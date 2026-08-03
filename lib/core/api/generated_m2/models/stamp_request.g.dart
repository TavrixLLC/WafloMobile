// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stamp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StampRequest _$StampRequestFromJson(Map<String, dynamic> json) => StampRequest(
  qrPayload: json['qrPayload'] as String,
  amount: (json['amount'] as num).toInt(),
  locale: json['locale'] == null
      ? null
      : StampRequestLocale.fromJson(json['locale'] as String),
  purchaseAmountMinor: (json['purchaseAmountMinor'] as num?)?.toInt(),
  purchaseCurrency: json['purchaseCurrency'],
  merchantTransactionReference: json['merchantTransactionReference'] as String?,
  managerOverride: json['managerOverride'] == null
      ? null
      : ManagerOverride.fromJson(
          json['managerOverride'] as Map<String, dynamic>,
        ),
  clientObservedAt: json['clientObservedAt'] == null
      ? null
      : DateTime.parse(json['clientObservedAt'] as String),
);

Map<String, dynamic> _$StampRequestToJson(StampRequest instance) =>
    <String, dynamic>{
      'qrPayload': instance.qrPayload,
      'locale': _$StampRequestLocaleEnumMap[instance.locale],
      'amount': instance.amount,
      'purchaseAmountMinor': instance.purchaseAmountMinor,
      'purchaseCurrency': instance.purchaseCurrency,
      'merchantTransactionReference': instance.merchantTransactionReference,
      'managerOverride': instance.managerOverride,
      'clientObservedAt': instance.clientObservedAt?.toIso8601String(),
    };

const _$StampRequestLocaleEnumMap = {
  StampRequestLocale.en: 'en',
  StampRequestLocale.ar: 'ar',
  StampRequestLocale.$unknown: r'$unknown',
};
