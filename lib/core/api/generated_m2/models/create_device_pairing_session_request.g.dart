// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_device_pairing_session_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDevicePairingSessionRequest _$CreateDevicePairingSessionRequestFromJson(
  Map<String, dynamic> json,
) => CreateDevicePairingSessionRequest(
  staffMemberId: json['staffMemberId'] as String,
  locations: (json['locations'] as List<dynamic>)
      .map((e) => Locations.fromJson(e as Map<String, dynamic>))
      .toList(),
  expiresInMinutes: (json['expiresInMinutes'] as num?)?.toInt() ?? 10,
  deviceLabelSuggestion: json['deviceLabelSuggestion'] as String?,
);

Map<String, dynamic> _$CreateDevicePairingSessionRequestToJson(
  CreateDevicePairingSessionRequest instance,
) => <String, dynamic>{
  'staffMemberId': instance.staffMemberId,
  'locations': instance.locations,
  'deviceLabelSuggestion': instance.deviceLabelSuggestion,
  'expiresInMinutes': instance.expiresInMinutes,
};
