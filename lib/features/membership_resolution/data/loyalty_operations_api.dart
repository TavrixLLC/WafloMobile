import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/money/minor_unit_money.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';

abstract interface class LoyaltyOperationsApi {
  Future<ResolvedMembership> resolveMembership({
    required String qrPayload,
    required String locale,
  });

  Future<StampOperationResult> issueStamps({
    required String qrPayload,
    required String locale,
    required String commandId,
    required StampOperationInput input,
  });

  Future<RedemptionOperationResult> redeemReward({
    required String qrPayload,
    required String locale,
    required String commandId,
    required RedemptionOperationInput input,
  });

  Future<CommandRecoveryResult> commandStatus(String commandId);
}

typedef SessionRefresher = Future<StaffDeviceSession> Function();

final class SignedLoyaltyOperationsApi implements LoyaltyOperationsApi {
  SignedLoyaltyOperationsApi({
    required Dio dio,
    required DeviceRequestSigner signer,
    required ApiErrorDecoder errorDecoder,
    required StaffDeviceSessionRepository sessionRepository,
    required SessionRefresher refreshSession,
    required bool allowInsecureAssets,
  }) : // Public named parameters intentionally initialize private fields.
       // ignore: prefer_initializing_formals
       _dio = dio,
       // ignore: prefer_initializing_formals
       _signer = signer,
       // ignore: prefer_initializing_formals
       _errorDecoder = errorDecoder,
       // ignore: prefer_initializing_formals
       _sessionRepository = sessionRepository,
       // ignore: prefer_initializing_formals
       _refreshSession = refreshSession,
       // ignore: prefer_initializing_formals
       _allowInsecureAssets = allowInsecureAssets;

  static const _resolvePath = '/v1/staff/memberships/resolve';
  static const _stampPath = '/v1/staff/operations/stamps';
  static const _redeemPath = '/v1/staff/operations/redeem';
  static const _commandPathPrefix = '/v1/staff/operations/commands/';

  final Dio _dio;
  final DeviceRequestSigner _signer;
  final ApiErrorDecoder _errorDecoder;
  final StaffDeviceSessionRepository _sessionRepository;
  final SessionRefresher _refreshSession;
  final bool _allowInsecureAssets;

  @override
  Future<ResolvedMembership> resolveMembership({
    required String qrPayload,
    required String locale,
  }) async {
    _validateQr(qrPayload);
    _validateLocale(locale);
    final response = await _send(
      method: 'POST',
      path: _resolvePath,
      body: <String, Object?>{'qrPayload': qrPayload},
      mutation: false,
    );
    final wrapper = _jsonMap(response.data);
    final requestId = _requestId(wrapper);
    final membership = ResolvedMembership.fromJson(
      _jsonMap(wrapper['data']),
      allowInsecureAssets: _allowInsecureAssets,
      responseRequestId: requestId,
      receivedAt: DateTime.now(),
    );
    return membership;
  }

  @override
  Future<StampOperationResult> issueStamps({
    required String qrPayload,
    required String locale,
    required String commandId,
    required StampOperationInput input,
  }) async {
    _validateQr(qrPayload);
    _validateLocale(locale);
    final purchaseCurrency = input.purchaseCurrency == null
        ? null
        : CurrencyMetadata.normalizeCode(input.purchaseCurrency!);
    final body = <String, Object?>{
      'qrPayload': qrPayload,
      'amount': input.amount,
      if (input.purchaseAmountMinor != null)
        'purchaseAmountMinor': input.purchaseAmountMinor,
      'purchaseCurrency': ?purchaseCurrency,
      if (input.merchantTransactionReference != null)
        'merchantTransactionReference': input.merchantTransactionReference,
      'clientObservedAt': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await _send(
      method: 'POST',
      path: _stampPath,
      body: body,
      mutation: true,
      idempotencyKey: commandId,
    );
    final wrapper = _jsonMap(response.data);
    final requestId = _requestId(wrapper);
    final result = StampOperationResult.fromJson(
      _jsonMap(wrapper['data']),
      responseRequestId: requestId,
    );
    if (result.commandId != commandId) {
      throw const M2ContractViolation('STAMP_RESPONSE_ID_MISMATCH');
    }
    return result;
  }

  @override
  Future<RedemptionOperationResult> redeemReward({
    required String qrPayload,
    required String locale,
    required String commandId,
    required RedemptionOperationInput input,
  }) async {
    _validateQr(qrPayload);
    _validateLocale(locale);
    final response = await _send(
      method: 'POST',
      path: _redeemPath,
      body: <String, Object?>{
        'qrPayload': qrPayload,
        'rewardEntitlementPublicId': input.entitlementPublicId,
        if (input.note != null) 'note': input.note,
        if (input.managerApprovalPublicId != null)
          'managerApprovalPublicId': input.managerApprovalPublicId,
      },
      mutation: true,
      idempotencyKey: commandId,
    );
    final wrapper = _jsonMap(response.data);
    final requestId = _requestId(wrapper);
    final result = RedemptionOperationResult.fromJson(
      _jsonMap(wrapper['data']),
      responseRequestId: requestId,
    );
    if (result.commandId != commandId) {
      throw const M2ContractViolation('REDEMPTION_RESPONSE_ID_MISMATCH');
    }
    return result;
  }

  @override
  Future<CommandRecoveryResult> commandStatus(String commandId) async {
    final path = '$_commandPathPrefix${Uri.encodeComponent(commandId)}';
    final response = await _send(
      method: 'GET',
      path: path,
      body: null,
      mutation: false,
    );
    final wrapper = _jsonMap(response.data);
    final requestId = _requestId(wrapper);
    final result = CommandRecoveryResult.fromJson(
      _jsonMap(wrapper['data']),
      responseRequestId: requestId,
    );
    if (result.commandId != commandId) {
      throw const M2ContractViolation('COMMAND_RESPONSE_ID_MISMATCH');
    }
    return result;
  }

  Future<Response<Object?>> _send({
    required String method,
    required String path,
    required Map<String, Object?>? body,
    required bool mutation,
    String? idempotencyKey,
  }) async {
    final encoded = body == null ? null : jsonEncode(body);
    final exactBytes = encoded == null ? const <int>[] : utf8.encode(encoded);
    final maximumAttempts = mutation ? 2 : 1;
    for (var attempt = 0; attempt < maximumAttempts; attempt += 1) {
      final session = await _activeSession();
      final headers = await _signer.sign(
        method: method,
        canonicalPath: path,
        exactBodyBytes: exactBytes,
        accessToken: session.accessToken,
        devicePublicId: session.devicePublicId,
        deviceSessionId: session.sessionId,
        organizationId: session.organizationId,
      );
      final httpHeaders = headers.toHttpHeaders();
      if (idempotencyKey != null) {
        httpHeaders['x-idempotency-key'] = idempotencyKey;
      }
      try {
        return await _dio.request<Object?>(
          path,
          data: encoded,
          options: Options(
            method: method,
            headers: httpHeaders,
            contentType: encoded == null ? null : Headers.jsonContentType,
            responseType: ResponseType.json,
            followRedirects: false,
          ),
        );
      } on DioException catch (error) {
        if (error.response != null) {
          throw _errorDecoder.decode(error);
        }
        final definitelyPreResponse =
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.connectionError;
        if (mutation && definitelyPreResponse && attempt == 0) {
          continue;
        }
        if (mutation && !definitelyPreResponse) {
          throw const ApiFailure(
            'OPERATION_RESULT_UNKNOWN',
            responseReceived: false,
          );
        }
        throw const NetworkFailure();
      } on AppFailure {
        rethrow;
      } on Object {
        if (mutation) {
          throw const ApiFailure(
            'OPERATION_RESULT_UNKNOWN',
            responseReceived: false,
          );
        }
        rethrow;
      }
    }
    throw const NetworkFailure();
  }

  Future<StaffDeviceSession> _activeSession() async {
    final current = await _sessionRepository.read();
    if (current == null) {
      throw const ApiFailure('STAFF_DEVICE_NOT_ACTIVE', httpStatus: 401);
    }
    if (current.isReview) {
      throw const LocalSecurityFailure('LEGACY_REVIEW_SESSION_FORBIDDEN');
    }
    final now = DateTime.now().toUtc();
    if (!current.accessExpiresAt.isAfter(now)) {
      throw const ApiFailure('STAFF_DEVICE_SESSION_EXPIRED', httpStatus: 401);
    }
    if (current.accessExpiresAt.difference(now) <= const Duration(minutes: 5)) {
      return _refreshSession();
    }
    return current;
  }

  static Map<String, Object?> _jsonMap(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    throw const M2ContractViolation('INVALID_RESPONSE_BODY');
  }

  static String _requestId(Map<String, Object?> wrapper) {
    final value = wrapper['requestId'];
    if (value is! String || value.isEmpty || value.length > 160) {
      throw const M2ContractViolation('REQUEST_ID_INVALID');
    }
    return value;
  }

  static void _validateQr(String qrPayload) {
    if (qrPayload.length < 40 || qrPayload.length > 220) {
      throw const ApiFailure('MEMBERSHIP_CREDENTIAL_INVALID');
    }
  }

  static void _validateLocale(String locale) {
    if (locale != 'en' && locale != 'ar') {
      throw const M2ContractViolation('LOCALE_INVALID');
    }
  }
}
