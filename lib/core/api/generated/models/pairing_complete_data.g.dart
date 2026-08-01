// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_complete_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingCompleteData _$PairingCompleteDataFromJson(Map<String, dynamic> json) =>
    PairingCompleteData(
      device: DeviceSummary.fromJson(json['device'] as Map<String, dynamic>),
      session: DeviceSessionCredentials.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      context: PairingCompleteContext.fromJson(
        json['context'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PairingCompleteDataToJson(
  PairingCompleteData instance,
) => <String, dynamic>{
  'device': instance.device,
  'session': instance.session,
  'context': instance.context,
};
