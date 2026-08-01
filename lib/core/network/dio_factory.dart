import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';

final class DioFactory {
  const DioFactory();

  Dio create(AppEnvironment environment) {
    final dio = Dio(
      BaseOptions(
        baseUrl: environment.apiBaseUrl.toString(),
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        followRedirects: false,
        maxRedirects: 0,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    dio.interceptors.add(const SafeResponseInterceptor());
    return dio;
  }
}

final class SafeResponseInterceptor extends Interceptor {
  const SafeResponseInterceptor();

  static const maximumResponseBytes = 1024 * 1024;

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
    if (response.statusCode != 204 &&
        !contentType.toLowerCase().contains('application/json')) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: const ApiFailure('UNEXPECTED_CONTENT_TYPE'),
        ),
      );
      return;
    }
    final contentLength = int.tryParse(
      response.headers.value(Headers.contentLengthHeader) ?? '',
    );
    final estimatedLength =
        contentLength ??
        (response.data == null
            ? 0
            : utf8.encode(jsonEncode(response.data)).length);
    if (estimatedLength > maximumResponseBytes) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: const ApiFailure('RESPONSE_TOO_LARGE'),
        ),
      );
      return;
    }
    handler.next(response);
  }
}
