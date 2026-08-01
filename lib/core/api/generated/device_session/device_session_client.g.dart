// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_session_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _DeviceSessionClient implements DeviceSessionClient {
  _DeviceSessionClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<SessionRefreshSuccess> refreshStaffDeviceSession({
    required String xWafloDeviceId,
    required String xWafloDeviceSessionId,
    required String xWafloRequestId,
    required DateTime xWafloTimestamp,
    required String xWafloNonce,
    required String xWafloBodySha256,
    required String xWafloSignature,
    required SessionRefreshRequest body,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'X-Waflo-Device-Id': xWafloDeviceId,
      r'X-Waflo-Device-Session-Id': xWafloDeviceSessionId,
      r'X-Waflo-Request-Id': xWafloRequestId,
      r'X-Waflo-Timestamp': xWafloTimestamp,
      r'X-Waflo-Nonce': xWafloNonce,
      r'X-Waflo-Body-Sha256': xWafloBodySha256,
      r'X-Waflo-Signature': xWafloSignature,
    };
    _headers.removeWhere((k, v) => v == null);
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
    late SessionRefreshSuccess _value;
    try {
      _value = SessionRefreshSuccess.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> logoutStaffDeviceSession({
    required String xWafloDeviceId,
    required String xWafloDeviceSessionId,
    required String xWafloRequestId,
    required DateTime xWafloTimestamp,
    required String xWafloNonce,
    required String xWafloBodySha256,
    required String xWafloSignature,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'X-Waflo-Device-Id': xWafloDeviceId,
      r'X-Waflo-Device-Session-Id': xWafloDeviceSessionId,
      r'X-Waflo-Request-Id': xWafloRequestId,
      r'X-Waflo-Timestamp': xWafloTimestamp,
      r'X-Waflo-Nonce': xWafloNonce,
      r'X-Waflo-Body-Sha256': xWafloBodySha256,
      r'X-Waflo-Signature': xWafloSignature,
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
  Future<DeviceContextSuccess> getStaffDeviceContext({
    required String xWafloDeviceId,
    required String xWafloDeviceSessionId,
    required String xWafloRequestId,
    required DateTime xWafloTimestamp,
    required String xWafloNonce,
    required String xWafloBodySha256,
    required String xWafloSignature,
    RequestOptions? options,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'X-Waflo-Device-Id': xWafloDeviceId,
      r'X-Waflo-Device-Session-Id': xWafloDeviceSessionId,
      r'X-Waflo-Request-Id': xWafloRequestId,
      r'X-Waflo-Timestamp': xWafloTimestamp,
      r'X-Waflo-Nonce': xWafloNonce,
      r'X-Waflo-Body-Sha256': xWafloBodySha256,
      r'X-Waflo-Signature': xWafloSignature,
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
    late DeviceContextSuccess _value;
    try {
      _value = DeviceContextSuccess.fromJson(_result.data!);
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
