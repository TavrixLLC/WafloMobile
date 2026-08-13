import 'package:dio/dio.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';

final class DioReviewAccessAuthorizationApi
    implements ReviewAccessAuthorizationApi {
  const DioReviewAccessAuthorizationApi(this._dio, this._errorDecoder);

  static const _path = '/v1/staff/review-access/authorize';

  final Dio _dio;
  final ApiErrorDecoder _errorDecoder;

  @override
  Future<PairingClaimResult> authorize(
    ReviewAccessAuthorizeCommand command,
  ) async {
    try {
      final response = await _dio.post<Object?>(
        _path,
        data: <String, Object?>{
          'reviewAccessCode': command.reviewAccessCode,
          'installationId': command.installationId,
          'publicKey': command.publicKey,
          'platform': command.metadata.platform.name.toUpperCase(),
          'appVersion': command.metadata.appVersion,
          'osVersion': ?command.metadata.osVersion,
          'model': ?command.metadata.model,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          followRedirects: false,
        ),
      );
      final envelope = _jsonMap(response.data);
      final data = _jsonMap(envelope['data']);
      final pairingPublicId = _string(data, 'pairingPublicId', 64);
      final challenge = _string(data, 'challenge', 256);
      final signatureAlgorithm = _string(data, 'signatureAlgorithm', 32);
      final message = _string(data, 'message', 1024);
      final expiresAt = DateTime.tryParse(
        _string(data, 'challengeExpiresAt', 64),
      );
      if (expiresAt == null) {
        throw const ApiFailure('INVALID_RESPONSE_BODY');
      }
      return PairingClaimResult(
        pairingPublicId: pairingPublicId,
        challenge: challenge,
        challengeExpiresAt: expiresAt.toUtc(),
        signatureAlgorithm: signatureAlgorithm,
        message: message,
      );
    } on Object catch (error) {
      throw _errorDecoder.decode(error);
    }
  }

  static Map<String, Object?> _jsonMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const ApiFailure('INVALID_RESPONSE_BODY');
  }

  static String _string(Map<String, Object?> value, String field, int maximum) {
    final result = value[field];
    if (result is! String || result.isEmpty || result.length > maximum) {
      throw const ApiFailure('INVALID_RESPONSE_BODY');
    }
    return result;
  }
}
