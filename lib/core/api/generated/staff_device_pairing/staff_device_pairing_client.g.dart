// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_device_pairing_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _StaffDevicePairingClient implements StaffDevicePairingClient {
  _StaffDevicePairingClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<PostV1StaffDevicesPairingClaimResponse>
  staffDevicePairingControllerClaim({
    required DevicePairingClaimRequest body,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _options = newOptions.copyWith(
      method: 'POST',
      baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
      queryParameters: queryParameters,
      path: '/v1/staff/devices/pairing/claim',
    )..data = _data;
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostV1StaffDevicesPairingClaimResponse _value;
    try {
      _value = PostV1StaffDevicesPairingClaimResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostV1StaffDevicesPairingChallengeResponse>
  staffDevicePairingControllerChallenge({
    required DevicePairingRecoveryRequest body,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _options = newOptions.copyWith(
      method: 'POST',
      baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
      queryParameters: queryParameters,
      path: '/v1/staff/devices/pairing/challenge',
    )..data = _data;
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostV1StaffDevicesPairingChallengeResponse _value;
    try {
      _value = PostV1StaffDevicesPairingChallengeResponse.fromJson(
        _result.data!,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostV1StaffDevicesPairingCompleteResponse>
  staffDevicePairingControllerComplete({
    required DevicePairingCompleteRequest body,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _options = newOptions.copyWith(
      method: 'POST',
      baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
      queryParameters: queryParameters,
      path: '/v1/staff/devices/pairing/complete',
    )..data = _data;
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostV1StaffDevicesPairingCompleteResponse _value;
    try {
      _value = PostV1StaffDevicesPairingCompleteResponse.fromJson(
        _result.data!,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostV1StaffDevicesSessionRefreshResponse>
  staffDevicePairingControllerRefresh({
    required StaffDeviceSessionRefreshRequest body,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _options = newOptions.copyWith(
      method: 'POST',
      baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
      queryParameters: queryParameters,
      path: '/v1/staff/devices/session/refresh',
    )..data = _data;
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostV1StaffDevicesSessionRefreshResponse _value;
    try {
      _value = PostV1StaffDevicesSessionRefreshResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> staffDevicePairingControllerLogout({
    required String authorization,
    required String xWafloDeviceId,
    required String xWafloDeviceSessionId,
    required String xWafloRequestId,
    required String xWafloTimestamp,
    required String xWafloNonce,
    required String xWafloBodySha256,
    required String xWafloSignature,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'authorization': authorization,
      r'x-waflo-device-id': xWafloDeviceId,
      r'x-waflo-device-session-id': xWafloDeviceSessionId,
      r'x-waflo-request-id': xWafloRequestId,
      r'x-waflo-timestamp': xWafloTimestamp,
      r'x-waflo-nonce': xWafloNonce,
      r'x-waflo-body-sha256': xWafloBodySha256,
      r'x-waflo-signature': xWafloSignature,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _options = newOptions.copyWith(
      method: 'POST',
      baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
      queryParameters: queryParameters,
      path: '/v1/staff/devices/session/logout',
    )..data = _data;
    await _dio.fetch<void>(_options);
  }

  @override
  Future<GetV1StaffDeviceContextResponse> staffDevicePairingControllerContext({
    required String authorization,
    required String xWafloDeviceId,
    required String xWafloDeviceSessionId,
    required String xWafloRequestId,
    required String xWafloTimestamp,
    required String xWafloNonce,
    required String xWafloBodySha256,
    required String xWafloSignature,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'authorization': authorization,
      r'x-waflo-device-id': xWafloDeviceId,
      r'x-waflo-device-session-id': xWafloDeviceSessionId,
      r'x-waflo-request-id': xWafloRequestId,
      r'x-waflo-timestamp': xWafloTimestamp,
      r'x-waflo-nonce': xWafloNonce,
      r'x-waflo-body-sha256': xWafloBodySha256,
      r'x-waflo-signature': xWafloSignature,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _options = newOptions.copyWith(
      method: 'GET',
      baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
      queryParameters: queryParameters,
      path: '/v1/staff/device-context',
    )..data = _data;
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late GetV1StaffDeviceContextResponse _value;
    try {
      _value = GetV1StaffDeviceContextResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions newRequestOptions(Object? options) {
    if (options is RequestOptions) {
      return options;
    }
    if (options is Options) {
      return RequestOptions(
        method: options.method,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        extra: options.extra,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType?.toString(),
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        requestEncoder: options.requestEncoder,
        responseDecoder: options.responseDecoder,
        path: '',
      );
    }
    return RequestOptions(path: '');
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
