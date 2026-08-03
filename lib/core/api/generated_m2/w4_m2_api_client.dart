// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'fallback/fallback_client.dart';

/// Waflo Staff Mobile M2 Contract `vw4-m2-1.0.0`.
///
/// M1 pairing/session/context plus the M2 mobile operations subset. QR payloads are bearer credentials and must never be logged or retained for recovery.
class W4M2ApiClient {
  W4M2ApiClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => 'w4-m2-1.0.0';

  FallbackClient? _fallback;

  FallbackClient get fallback =>
      _fallback ??= FallbackClient(_dio, baseUrl: _baseUrl);
}
