// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_complete_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingCompleteSuccess _$PairingCompleteSuccessFromJson(
  Map<String, dynamic> json,
) => PairingCompleteSuccess(
  data: PairingCompleteData.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$PairingCompleteSuccessToJson(
  PairingCompleteSuccess instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
