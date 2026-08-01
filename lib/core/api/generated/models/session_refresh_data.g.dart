// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_refresh_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRefreshData _$SessionRefreshDataFromJson(Map<String, dynamic> json) =>
    SessionRefreshData(
      session: DeviceSessionCredentials.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SessionRefreshDataToJson(SessionRefreshData instance) =>
    <String, dynamic>{'session': instance.session};
