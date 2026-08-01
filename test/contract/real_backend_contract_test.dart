import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/api/generated/staff_device_pairing/staff_device_pairing_client.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/data/generated_pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

final _enabled = Platform.environment['WAFLO_RUN_BACKEND_CONTRACT'] == 'true';
final _apiUrl = Platform.environment['WAFLO_CONTRACT_API_URL'] ?? '';
final _controlUrl = Platform.environment['WAFLO_CONTRACT_CONTROL_URL'] ?? '';
final _controlSecret =
    Platform.environment['WAFLO_CONTRACT_CONTROL_SECRET'] ?? '';

void main() {
  group(
    'real W4 development contract gate',
    () {
      late _FixtureControl control;
      late _ContractDevice primary;
      late String primaryQr;
      late StaffDeviceSession oldSession;

      setUpAll(() async {
        expect(Uri.tryParse(_apiUrl)?.isAbsolute, isTrue);
        expect(Uri.tryParse(_controlUrl)?.isAbsolute, isTrue);
        expect(_controlSecret, isNotEmpty);
        SharedPreferences.setMockInitialValues({});
        control = _FixtureControl(_controlUrl, _controlSecret);
        primary = await _ContractDevice.create(_apiUrl);
        primaryQr = await control.createPairing();
      });

      tearDownAll(() async {
        await control.cleanup();
      });

      test('01 claim creates an ephemeral claimed pairing', () async {
        final claim = await primary.claim(primaryQr);
        expect(claim.signatureAlgorithm, 'Ed25519');
        expect(claim.challenge, isNotEmpty);
      });

      test('02 challenge recovers the exact claimed message', () async {
        final recovered = await primary.challenge();
        expect(recovered.signatureAlgorithm, 'Ed25519');
      });

      test('03 complete establishes a signed device session', () async {
        final session = await primary.complete();
        expect(session.devicePublicId, isNotEmpty);
        expect(await primary.sessions.read(), isNotNull);
      });

      test('04 device-context returns authoritative safe context', () async {
        final context = await primary.manager.loadContext(
          refreshIfExpired: false,
        );
        expect(context.organization.displayName, isNotEmpty);
        expect(context.staff.displayName, isNotEmpty);
        expect(context.device.publicId, primary.session.devicePublicId);
        expect(context.assignedLocations, isNotEmpty);
      });

      test('05 refresh rotates the real W4 session', () async {
        oldSession = primary.session;
        final replacement = await primary.manager.refreshSingleFlight();
        primary.session = replacement;
        expect(replacement.sessionId, isNot(oldSession.sessionId));
        expect(replacement.refreshToken, isNot(oldSession.refreshToken));
      });

      test('06 the old refresh token is rejected after rotation', () async {
        await expectLater(
          primary.api.refresh(oldSession),
          throwsA(
            isA<ApiFailure>().having(
              (failure) => failure.safeCode,
              'safeCode',
              'STAFF_DEVICE_NOT_ACTIVE',
            ),
          ),
        );
      });

      test('07 revoked is a real backend state and clears session', () async {
        final device = await _pairedDevice(control);
        await control.setState(device.session.devicePublicId, 'revoked');
        await _expectFailure(
          device.manager.loadContext(refreshIfExpired: false),
          'STAFF_DEVICE_REVOKED',
        );
        expect(await device.sessions.read(), isNull);
      });

      test('08 compromised is distinct and clears session', () async {
        final device = await _pairedDevice(control);
        await control.setState(device.session.devicePublicId, 'compromised');
        await _expectFailure(
          device.manager.loadContext(refreshIfExpired: false),
          'STAFF_DEVICE_COMPROMISED',
        );
        expect(await device.sessions.read(), isNull);
      });

      test('09 expired session is distinct and clears credentials', () async {
        final device = await _pairedDevice(control);
        await control.setState(device.session.devicePublicId, 'sessionExpired');
        await _expectFailure(
          device.manager.loadContext(refreshIfExpired: false),
          'STAFF_DEVICE_SESSION_EXPIRED',
        );
        expect(await device.sessions.read(), isNull);
      });

      test('10 update-required blocks but preserves the session', () async {
        final device = await _pairedDevice(control);
        await control.setState(device.session.devicePublicId, 'updateRequired');
        await _expectFailure(
          device.manager.loadContext(refreshIfExpired: false),
          'APP_UPDATE_REQUIRED',
        );
        expect(await device.sessions.read(), isNotNull);
        expect(
          (await device.lifecycle.read())?.state,
          LocalLifecycleState.paired,
        );
      });

      test('11 logout revokes W4 and clears all local credentials', () async {
        final directDevice = await _pairedDevice(control);
        await directDevice.api.logout(directDevice.session);
        await _expectFailure(
          directDevice.api.getContext(directDevice.session),
          'STAFF_DEVICE_NOT_ACTIVE',
        );

        final device = await _pairedDevice(control);
        expect((await device.manager.logout()).serverReached, isTrue);
        expect(await device.sessions.read(), isNull);
        expect(await device.identity.load(), isNull);
      });
    },
    skip:
        _enabled &&
            _apiUrl.isNotEmpty &&
            _controlUrl.isNotEmpty &&
            _controlSecret.isNotEmpty
        ? false
        : 'Run tool/run_real_w4_contract_gate.dart against approved development W4.',
  );
}

Future<_ContractDevice> _pairedDevice(_FixtureControl control) async {
  final device = await _ContractDevice.create(_apiUrl);
  await device.claim(await control.createPairing());
  await device.challenge();
  await device.complete();
  return device;
}

Future<void> _expectFailure(Future<Object?> operation, String expected) async {
  await expectLater(
    operation,
    throwsA(
      isA<ApiFailure>().having(
        (failure) => failure.safeCode,
        'safeCode',
        expected,
      ),
    ),
  );
}

final class _ContractDevice {
  _ContractDevice._({
    required this.identity,
    required this.sessions,
    required this.lifecycle,
    required this.pairingApi,
    required this.api,
    required this.manager,
  });

  final DeviceIdentityRepository identity;
  final StaffDeviceSessionRepository sessions;
  final LocalLifecycleRepository lifecycle;
  final PairingApi pairingApi;
  final SignedDeviceApi api;
  final SessionManager manager;
  PairingQrPayload? _payload;
  PairingClaimResult? _claim;
  PairingChallengeResult? _challenge;
  late StaffDeviceSession session;

  static Future<_ContractDevice> create(String apiUrl) async {
    final store = MemorySecureKeyValueStore();
    final identity = DeviceIdentityRepository(store);
    final sessions = StaffDeviceSessionRepository(store);
    final lifecycle = LocalLifecycleRepository(store);
    final transactions = PairingTransactionRepository(store);
    final dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    final decoder = const ApiErrorDecoder();
    final api = SignedDeviceApi(dio, DeviceRequestSigner(identity), decoder);
    final manager = SessionManager(
      sessions,
      api,
      identity,
      PreferencesRepository(await SharedPreferences.getInstance()),
      lifecycleRepository: lifecycle,
      transactionRepository: transactions,
    );
    return _ContractDevice._(
      identity: identity,
      sessions: sessions,
      lifecycle: lifecycle,
      pairingApi: GeneratedPairingApi(StaffDevicePairingClient(dio), decoder),
      api: api,
      manager: manager,
    );
  }

  Future<PairingClaimResult> claim(String qr) async {
    final payload = const PairingQrParser(
      expectedEnvironment: 'development',
    ).parse(qr);
    final localIdentity = await identity.loadOrCreate();
    final result = await pairingApi.claim(
      PairingClaimCommand(
        pairingToken: payload.rawToken,
        installationId: localIdentity.installationId,
        publicKey: localIdentity.publicKey,
        metadata: await const _ContractMetadata().load(),
      ),
    );
    expect(result.pairingPublicId, payload.pairingPublicId);
    _payload = payload;
    _claim = result;
    return result;
  }

  Future<PairingChallengeResult> challenge() async {
    final payload = _payload!;
    final claim = _claim!;
    final localIdentity = (await identity.load())!;
    final result = await pairingApi.challenge(payload.pairingPublicId);
    expect(result.pairingPublicId, payload.pairingPublicId);
    expect(result.challenge, claim.challenge);
    expect(result.message, claim.message);
    expect(
      result.message,
      [
        'waflo-pair-challenge-v1',
        result.pairingPublicId,
        result.challenge,
        localIdentity.installationId,
      ].join('\n'),
    );
    _challenge = result;
    return result;
  }

  Future<StaffDeviceSession> complete() async {
    final recovered = _challenge!;
    final signature = await identity.signUtf8(recovered.message);
    session = await pairingApi.complete(
      PairingCompleteCommand(
        pairingPublicId: recovered.pairingPublicId,
        challenge: recovered.challenge,
        signature: signature,
        displayName: 'M1 ephemeral contract device',
      ),
    );
    await sessions.replaceAtomically(session);
    await lifecycle.mark(LocalLifecycleState.paired);
    return session;
  }
}

final class _FixtureControl {
  _FixtureControl(String baseUrl, String secret)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'x-waflo-contract-control': secret},
          connectTimeout: const Duration(seconds: 10),
        ),
      );

  final Dio _dio;

  Future<String> createPairing() async {
    final response = await _dio.post<Object?>('/fixture/create');
    final data = response.data;
    if (data is! Map<String, Object?> || data['pairingQr'] is! String) {
      throw StateError('W4 fixture returned an invalid create response.');
    }
    return data['pairingQr']! as String;
  }

  Future<void> setState(String devicePublicId, String state) async {
    await _dio.post<Object?>(
      '/fixture/state',
      data: {'devicePublicId': devicePublicId, 'state': state},
    );
  }

  Future<void> cleanup() async {
    await _dio.post<Object?>('/fixture/cleanup');
  }
}

final class _ContractMetadata implements DeviceMetadataProvider {
  const _ContractMetadata();

  @override
  Future<SafeDeviceMetadata> load() async => const SafeDeviceMetadata(
    platform: StaffMobilePlatform.android,
    appVersion: '1.0.0',
    osVersion: 'Flutter contract runner',
    model: 'Ephemeral W4 gate',
  );
}
