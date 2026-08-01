// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicePairingCompleteResponse _$DevicePairingCompleteResponseFromJson(
  Map<String, dynamic> json,
) => DevicePairingCompleteResponse(
  device: Device.fromJson(json['device'] as Map<String, dynamic>),
  session: Session.fromJson(json['session'] as Map<String, dynamic>),
  context: Context.fromJson(json['context'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DevicePairingCompleteResponseToJson(
  DevicePairingCompleteResponse instance,
) => <String, dynamic>{
  'device': instance.device,
  'session': instance.session,
  'context': instance.context,
};
