import 'package:dio/dio.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';

final class ApiErrorDecoder {
  const ApiErrorDecoder();

  AppFailure decode(Object error) {
    if (error is AppFailure) {
      return error;
    }
    if (error is! DioException) {
      return const ApiFailure('INTERNAL_ERROR', responseReceived: false);
    }
    if (error.response == null) {
      return const NetworkFailure();
    }
    final status = error.response?.statusCode;
    final Object? body = error.response?.data;
    if (body is Map<String, Object?>) {
      final Object? errorBody = body['error'];
      if (errorBody is Map<String, Object?>) {
        final code = errorBody['code'];
        final requestId = errorBody['requestId'];
        if (code is String) {
          return ApiFailure(
            code,
            requestId: requestId is String ? requestId : null,
            httpStatus: status,
          );
        }
      }
    }
    return ApiFailure(
      status != null && status >= 500 ? 'INTERNAL_ERROR' : 'REQUEST_REJECTED',
      httpStatus: status,
    );
  }
}
