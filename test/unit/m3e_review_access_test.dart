import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/review_access/data/signed_review_access_repository.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';

import '../support/fixtures.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('review credential format is distinct, uppercase, and bounded', () {
    expect(
      PairingFlowService.normalizeReviewAccessCode('abcd 2345'),
      'ABCD-2345',
    );
    expect(PairingFlowService.isValidReviewAccessCode('ABCD-2345'), isTrue);
    for (final value in ['123456', 'ABCI-2345', 'ABCD-10O1', 'ABCD-234']) {
      expect(
        PairingFlowService.isValidReviewAccessCode(value),
        isFalse,
        reason: value,
      );
    }
  });

  test(
    'review authorization uses the normal key challenge and stores no code',
    () async {
      final store = MemorySecureKeyValueStore();
      final sessions = StaffDeviceSessionRepository(store);
      final identity = DeviceIdentityRepository(store);
      final transactions = PairingTransactionRepository(store);
      final lifecycle = LocalLifecycleRepository(store);
      final sessionManager = SessionManager(
        sessions,
        const _SessionApi(),
        identity,
        PreferencesRepository(await SharedPreferences.getInstance()),
        lifecycleRepository: lifecycle,
        transactionRepository: transactions,
        now: () => DateTime.utc(2026, 8, 14, 12),
      );
      final reviewApi = _ReviewAuthorizationApi();
      final pairingApi = _CompletingPairingApi();
      final service = PairingFlowService(
        const PairingQrParser(expectedEnvironment: 'test'),
        identity,
        pairingApi,
        const _Metadata(),
        sessions,
        transactions,
        lifecycle,
        sessionManager,
        reviewAccessApi: reviewApi,
        now: () => DateTime.utc(2026, 8, 14, 12),
      );

      final result = await service.enterReviewAccess(
        'abcd 2345',
        onProgress: (_) {},
      );

      expect(reviewApi.receivedCode, 'ABCD-2345');
      expect(pairingApi.completeCommand?.sessionMode, StaffSessionMode.review);
      expect((await sessions.read())?.isReview, isTrue);
      expect(result.context.organization.displayName, 'Fixture Coffee');
      expect(store.snapshot.values.join(), isNot(contains('ABCD-2345')));
      expect(await transactions.read(), isNull);
    },
  );

  test('review session record is typed and legacy records remain normal', () {
    final review = fixtureSession(sessionMode: StaffSessionMode.review);
    final restored = StaffDeviceSession.fromJson(review.toJson());
    expect(restored.isReview, isTrue);

    final legacy = Map<String, Object?>.from(review.toJson())
      ..['recordVersion'] = 1
      ..remove('sessionMode');
    expect(StaffDeviceSession.fromJson(legacy).isReview, isFalse);
  });

  test(
    'Exit Demo clears the review session but preserves its device key',
    () async {
      final store = MemorySecureKeyValueStore();
      final sessions = StaffDeviceSessionRepository(store);
      final identity = DeviceIdentityRepository(store);
      final transactions = PairingTransactionRepository(store);
      final lifecycle = LocalLifecycleRepository(store);
      final originalIdentity = await identity.loadOrCreate();
      await sessions.replaceAtomically(
        fixtureSession(sessionMode: StaffSessionMode.review),
      );
      final manager = SessionManager(
        sessions,
        const _SessionApi(),
        identity,
        PreferencesRepository(await SharedPreferences.getInstance()),
        lifecycleRepository: lifecycle,
        transactionRepository: transactions,
      );

      final result = await manager.exitReviewMode();

      expect(result.serverReached, isTrue);
      expect(await sessions.read(), isNull);
      expect((await identity.load())?.publicKey, originalIdentity.publicKey);
      await expectLater(
        manager.exitReviewMode(),
        throwsA(isA<LocalSecurityFailure>()),
      );
    },
  );

  test('device context cannot cross a review/normal session boundary', () {
    final review = fixtureSession(sessionMode: StaffSessionMode.review);
    expect(
      () => SignedDeviceApi.validateSessionMode(const {}, review),
      throwsA(isA<ApiFailure>()),
    );
    expect(
      () => SignedDeviceApi.validateSessionMode(const {
        'sessionMode': 'NORMAL',
      }, review),
      throwsA(isA<ApiFailure>()),
    );
    expect(
      () => SignedDeviceApi.validateSessionMode(const {
        'sessionMode': 'REVIEW',
      }, review),
      returnsNormally,
    );
    expect(
      () => SignedDeviceApi.validateSessionMode(const {
        'sessionMode': 'REVIEW',
      }, fixtureSession()),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('normal session cannot call Review Tools', () async {
    final harness = await _RepositoryHarness.create(review: false);

    await expectLater(
      harness.repository.scenarios(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.safeCode,
          'safeCode',
          'REVIEW_SESSION_INVALID',
        ),
      ),
    );
    expect(harness.adapter.requests, isEmpty);
  });

  test(
    'review scenario and reset calls are signed, enumerated, and single-tenant',
    () async {
      final harness = await _RepositoryHarness.create(review: true);

      final scenarios = await harness.repository.scenarios();
      final selected = await harness.repository.select(
        ReviewScenario.customerActive,
      );
      final count = await harness.repository.reset();

      expect(scenarios.single.id, ReviewScenario.customerActive);
      expect(selected.progress, 5);
      expect(count, 7);
      expect(harness.adapter.requests, hasLength(3));
      final selectBody =
          jsonDecode(harness.adapter.requests[1].data! as String)
              as Map<String, Object?>;
      expect(selectBody['scenarioId'], 'CUSTOMER_ACTIVE_5_OF_8');
      expect(selectBody.keys, {'scenarioId', 'commandId'});
      final resetBody =
          jsonDecode(harness.adapter.requests[2].data! as String)
              as Map<String, Object?>;
      expect(resetBody.keys, {'commandId'});
      for (final request in harness.adapter.requests) {
        expect(request.headers['Authorization'], startsWith('Device '));
        expect(request.headers['X-Waflo-Signature'], isNotEmpty);
        expect(request.headers['X-Waflo-Nonce'], isNotEmpty);
        expect(request.path, startsWith('/v1/staff/review/'));
        expect(request.data?.toString(), isNot(contains('ABCD-2345')));
      }
      expect(
        harness.adapter.requests.map(
          (request) => request.headers['X-Waflo-Request-Id'],
        ),
        everyElement(isNotEmpty),
      );
      expect(
        harness.adapter.requests
            .map((request) => request.headers['X-Waflo-Request-Id'])
            .toSet(),
        hasLength(3),
      );
    },
  );
}

final class _ReviewAuthorizationApi implements ReviewAccessAuthorizationApi {
  String? receivedCode;

  @override
  Future<PairingClaimResult> authorize(
    ReviewAccessAuthorizeCommand command,
  ) async {
    receivedCode = command.reviewAccessCode;
    const pairingId = '00000000-0000-4000-8000-000000000501';
    const challenge = 'review-challenge-value-with-at-least-32-characters';
    return PairingClaimResult(
      pairingPublicId: pairingId,
      challenge: challenge,
      challengeExpiresAt: DateTime.utc(2026, 8, 14, 13),
      signatureAlgorithm: 'Ed25519',
      message: [
        'waflo-pair-challenge-v1',
        pairingId,
        challenge,
        command.installationId,
      ].join('\n'),
    );
  }
}

final class _CompletingPairingApi implements PairingApi {
  PairingCompleteCommand? completeCommand;

  @override
  Future<PairingClaimResult> claim(PairingClaimCommand command) =>
      throw StateError('Normal claim must not run in Review Access.');

  @override
  Future<PairingChallengeResult> challenge(String pairingPublicId) =>
      throw StateError('Challenge recovery is not expected in this fixture.');

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) async {
    completeCommand = command;
    return fixtureSession(sessionMode: command.sessionMode);
  }
}

final class _SessionApi implements DeviceSessionApi {
  const _SessionApi();

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async => fixtureContext();

  @override
  Future<void> logout(StaffDeviceSession current) async {}

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async =>
      fixtureSession(sessionMode: current.sessionMode);
}

final class _Metadata implements DeviceMetadataProvider {
  const _Metadata();

  @override
  Future<SafeDeviceMetadata> load() async => const SafeDeviceMetadata(
    platform: StaffMobilePlatform.android,
    appVersion: '1.0.0',
  );
}

final class _RepositoryHarness {
  const _RepositoryHarness({required this.repository, required this.adapter});

  final SignedReviewAccessRepository repository;
  final _ReviewAdapter adapter;

  static Future<_RepositoryHarness> create({required bool review}) async {
    final store = MemorySecureKeyValueStore();
    final sessions = StaffDeviceSessionRepository(store);
    await sessions.replaceAtomically(
      fixtureSession(
        sessionMode: review ? StaffSessionMode.review : StaffSessionMode.normal,
      ),
    );
    final identity = DeviceIdentityRepository(store);
    await identity.loadOrCreate();
    final adapter = _ReviewAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
      ..httpClientAdapter = adapter;
    return _RepositoryHarness(
      repository: SignedReviewAccessRepository(
        dio: dio,
        signer: DeviceRequestSigner(identity),
        sessionRepository: sessions,
        commandIds: FixedBusinessCommandIdGenerator(const [
          '10000000-0000-4000-8000-000000000001',
          '10000000-0000-4000-8000-000000000002',
        ]),
        errorDecoder: const ApiErrorDecoder(),
      ),
      adapter: adapter,
    );
  }
}

final class _ReviewAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final scenario = <String, Object?>{
      'id': 'CUSTOMER_ACTIVE_5_OF_8',
      'progress': 5,
      'goal': 8,
      'rewardReady': false,
      'credentialStatus': 'ACTIVE',
    };
    final data = switch (options.path) {
      '/v1/staff/review/scenarios' => <String, Object?>{
        'sessionMode': 'REVIEW',
        'scenarios': [scenario],
      },
      '/v1/staff/review/scenarios/select' => scenario,
      '/v1/staff/review/reset' => <String, Object?>{
        'status': 'RESET',
        'scenarioCount': 7,
      },
      _ => throw StateError('Unexpected path: ${options.path}'),
    };
    return ResponseBody.fromString(
      jsonEncode({'data': data, 'requestId': 'fixture-request'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
