// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_operations_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _StaffOperationsClient implements StaffOperationsClient {
  _StaffOperationsClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<void> staffOperationsControllerResolve({
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
      path: '/v1/staff/memberships/resolve',
    )..data = _data;
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> staffOperationsControllerIssue({
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
      path: '/v1/staff/operations/stamps',
    )..data = _data;
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> staffOperationsControllerRedeem({
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
      path: '/v1/staff/operations/redeem',
    )..data = _data;
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> staffOperationsControllerReverse({
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
      path: '/v1/staff/operations/reverse',
    )..data = _data;
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> staffOperationsControllerStatus({
    required String operationPublicId,
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
      path: '/v1/staff/operations/${operationPublicId}',
    )..data = _data;
    await _dio.fetch<void>(_options);
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
