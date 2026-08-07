// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'fallback/fallback_client.dart';

/// Waflo M2 Staff Mobile Compatibility API `vwaflo-m2-mobile-contract-v1`.
///
/// Typed mobile compatibility surface over the authoritative signed W4 Staff-device API.
class W4M2ApiClient {
  W4M2ApiClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => 'waflo-m2-mobile-contract-v1';

  FallbackClient? _fallback;

  FallbackClient get fallback =>
      _fallback ??= FallbackClient(_dio, baseUrl: _baseUrl);
}
