import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';

final class SignedReviewAccessRepository implements ReviewAccessRepository {
  factory SignedReviewAccessRepository({
    required Dio dio,
    required DeviceRequestSigner signer,
    required StaffDeviceSessionRepository sessionRepository,
    required BusinessCommandIdGenerator commandIds,
    required ApiErrorDecoder errorDecoder,
  }) => SignedReviewAccessRepository._(
    dio,
    signer,
    sessionRepository,
    commandIds,
    errorDecoder,
  );

  const SignedReviewAccessRepository._(
    this._dio,
    this._signer,
    this._sessions,
    this._commandIds,
    this._errors,
  );

  final Dio _dio;
  final DeviceRequestSigner _signer;
  final StaffDeviceSessionRepository _sessions;
  final BusinessCommandIdGenerator _commandIds;
  final ApiErrorDecoder _errors;

  @override
  Future<List<ReviewScenarioSummary>> scenarios() async {
    final data = await _send('GET', '/v1/staff/review/scenarios', null);
    final values = data['scenarios'];
    if (data['sessionMode'] != 'REVIEW' || values is! List<Object?>) {
      throw const ApiFailure('INVALID_RESPONSE_BODY');
    }
    return values.map(_parseScenario).toList(growable: false);
  }

  @override
  Future<ReviewScenarioSummary> select(ReviewScenario scenario) async {
    final commandId = _commandIds.next();
    return _parseScenario(
      await _send(
        'POST',
        '/v1/staff/review/scenarios/select',
        jsonEncode(<String, Object?>{
          'scenarioId': scenario.wireValue,
          'commandId': commandId,
        }),
      ),
    );
  }

  @override
  Future<int> reset() async {
    final data = await _send(
      'POST',
      '/v1/staff/review/reset',
      jsonEncode(<String, Object?>{'commandId': _commandIds.next()}),
    );
    final count = data['scenarioCount'];
    if (data['status'] != 'RESET' || count is! int || count < 1 || count > 20) {
      throw const ApiFailure('INVALID_RESPONSE_BODY');
    }
    return count;
  }

  Future<Map<String, Object?>> _send(
    String method,
    String path,
    String? body,
  ) async {
    final session = await _sessions.read();
    if (session == null || !session.isReview) {
      throw const ApiFailure('REVIEW_SESSION_INVALID', httpStatus: 403);
    }
    final bodyBytes = body == null ? const <int>[] : utf8.encode(body);
    try {
      final headers = await _signer.sign(
        method: method,
        canonicalPath: path,
        exactBodyBytes: bodyBytes,
        accessToken: session.accessToken,
        devicePublicId: session.devicePublicId,
        deviceSessionId: session.sessionId,
        organizationId: session.organizationId,
      );
      final response = await _dio.request<Object?>(
        path,
        data: body,
        options: Options(
          method: method,
          headers: headers.toHttpHeaders(),
          contentType: body == null ? null : Headers.jsonContentType,
          responseType: ResponseType.json,
          followRedirects: false,
        ),
      );
      final envelope = _map(response.data);
      return _map(envelope['data']);
    } on Object catch (error) {
      throw _errors.decode(error);
    }
  }

  static ReviewScenarioSummary _parseScenario(Object? value) {
    final data = _map(value);
    final id = data['id'];
    final progress = data['progress'];
    final goal = data['goal'];
    final rewardReady = data['rewardReady'];
    final credentialStatus = data['credentialStatus'];
    if (id is! String ||
        progress is! int ||
        goal is! int ||
        rewardReady is! bool ||
        credentialStatus is! String ||
        progress < 0 ||
        goal < 1 ||
        progress > goal) {
      throw const ApiFailure('INVALID_RESPONSE_BODY');
    }
    late final ReviewScenario scenario;
    try {
      scenario = ReviewScenario.parse(id);
    } on FormatException {
      throw const ApiFailure('INVALID_RESPONSE_BODY');
    }
    return ReviewScenarioSummary(
      id: scenario,
      progress: progress,
      goal: goal,
      rewardReady: rewardReady,
      credentialStatus: credentialStatus,
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const ApiFailure('INVALID_RESPONSE_BODY');
  }
}
