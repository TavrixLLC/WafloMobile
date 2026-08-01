// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_refresh_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRefreshSuccess _$SessionRefreshSuccessFromJson(
  Map<String, dynamic> json,
) => SessionRefreshSuccess(
  data: SessionRefreshData.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$SessionRefreshSuccessToJson(
  SessionRefreshSuccess instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
