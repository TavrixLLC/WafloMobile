// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'pairing/pairing_client.dart';
import 'device_session/device_session_client.dart';

/// Waflo Staff Device API — Flutter M1 subset `vw4-round1-m1-v1`.
///
/// Approved mobile-safe subset for device pairing, session rotation/logout, and signed device context. Server messages are not localization strings; clients branch on error.code.
class W4M1ApiClient {
  W4M1ApiClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => 'w4-round1-m1-v1';

  PairingClient? _pairing;
  DeviceSessionClient? _deviceSession;

  PairingClient get pairing =>
      _pairing ??= PairingClient(_dio, baseUrl: _baseUrl);

  DeviceSessionClient get deviceSession =>
      _deviceSession ??= DeviceSessionClient(_dio, baseUrl: _baseUrl);
}
