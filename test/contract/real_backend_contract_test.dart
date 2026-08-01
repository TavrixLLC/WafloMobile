import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/api/generated/pairing/pairing_client.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/network/dio_factory.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/data/generated_pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

const _enabled = bool.fromEnvironment('WAFLO_RUN_BACKEND_CONTRACT');
const _apiUrl = String.fromEnvironment('WAFLO_CONTRACT_API_URL');
const _pairingQr = String.fromEnvironment('WAFLO_CONTRACT_PAIRING_QR');

void main() {
  test(
    'real local W4 pairing, context, refresh, and logout',
    () async {
      final environment = AppEnvironment(
        flavor: AppFlavor.development,
        apiBaseUrl: Uri.parse(_apiUrl),
        pairingEnvironment: 'development',
        logLevel: AppLogLevel.debug,
        allowTestAdapter: true,
        minimumVersionSource: 'backend',
        crashReportingEnabled: false,
        certificatePinningEnabled: false,
      );
      expect(environment.validate(), isEmpty);
      SharedPreferences.setMockInitialValues({});
      final store = MemorySecureKeyValueStore();
      final identity = DeviceIdentityRepository(store);
      final sessions = StaffDeviceSessionRepository(store);
      final dio = const DioFactory().create(environment);
      final pairingApi = GeneratedPairingApi(
        PairingClient(dio),
        const ApiErrorDecoder(),
      );
      final sessionApi = SignedDeviceApi(
        Dio(BaseOptions(baseUrl: environment.apiBaseUrl.toString())),
        DeviceRequestSigner(identity),
        const ApiErrorDecoder(),
      );
      final manager = SessionManager(
        sessions,
        sessionApi,
        identity,
        PreferencesRepository(await SharedPreferences.getInstance()),
      );
      final service = PairingFlowService(
        const PairingQrParser(expectedEnvironment: 'development'),
        identity,
        pairingApi,
        const _ContractMetadata(),
        sessions,
        PairingTransactionRepository(store),
        manager,
      );
      final result = await service.pair(_pairingQr, onProgress: (_) {});
      expect(result.context.devicePublicId, isNotEmpty);
      await manager.refreshSingleFlight();
      final logout = await manager.logout();
      expect(logout.serverReached, isTrue);
      expect(await sessions.read(), isNull);
    },
    skip: _enabled && _apiUrl.isNotEmpty && _pairingQr.isNotEmpty
        ? false
        : 'Set development-only WAFLO contract defines and start the seeded local backend.',
  );
}

final class _ContractMetadata implements DeviceMetadataProvider {
  const _ContractMetadata();

  @override
  Future<SafeDeviceMetadata> load() async => const SafeDeviceMetadata(
    platform: StaffMobilePlatform.android,
    appVersion: '1.0.0+1-contract',
    model: 'Flutter contract runner',
  );
}
