// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'staff_device_pairing/staff_device_pairing_client.dart';
import 'staff_operations/staff_operations_client.dart';

/// Waflo M1 Staff Mobile API `vw4-m1-contract-v1`.
///
/// Mobile-safe subset of the approved W4 backend contract.
class W4M1ApiClient {
  W4M1ApiClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => 'w4-m1-contract-v1';

  StaffDevicePairingClient? _staffDevicePairing;
  StaffOperationsClient? _staffOperations;

  StaffDevicePairingClient get staffDevicePairing =>
      _staffDevicePairing ??= StaffDevicePairingClient(_dio, baseUrl: _baseUrl);

  StaffOperationsClient get staffOperations =>
      _staffOperations ??= StaffOperationsClient(_dio, baseUrl: _baseUrl);
}
