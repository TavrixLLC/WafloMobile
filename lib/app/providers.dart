import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/api/generated/staff_device_pairing/staff_device_pairing_client.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/logging/safe_logger.dart';
import 'package:waflo_staff/core/network/dio_factory.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/data/generated_pairing_api.dart';
import 'package:waflo_staff/features/pairing/data/platform_device_metadata.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/settings/presentation/preferences_controllers.dart';

final environmentProvider = Provider<AppEnvironment>(
  (ref) => throw StateError('AppEnvironment was not bootstrapped.'),
);
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences was not bootstrapped.'),
);
final secureStoreProvider = Provider<SecureKeyValueStore>(
  (ref) => PlatformSecureKeyValueStore(),
);
final safeLoggerProvider = Provider<SafeLogger>(
  (ref) => SafeLogger(ref.watch(environmentProvider).logLevel),
);
final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(sharedPreferencesProvider)),
);
final apiErrorDecoderProvider = Provider<ApiErrorDecoder>(
  (ref) => const ApiErrorDecoder(),
);
final publicDioProvider = Provider<Dio>(
  (ref) => const DioFactory().create(ref.watch(environmentProvider)),
);
final signedDioProvider = Provider<Dio>(
  (ref) => const DioFactory().create(ref.watch(environmentProvider)),
);
final identityRepositoryProvider = Provider<DeviceIdentityRepository>(
  (ref) => DeviceIdentityRepository(ref.watch(secureStoreProvider)),
);
final sessionRepositoryProvider = Provider<StaffDeviceSessionRepository>(
  (ref) => StaffDeviceSessionRepository(ref.watch(secureStoreProvider)),
);
final pairingTransactionRepositoryProvider =
    Provider<PairingTransactionRepository>(
      (ref) => PairingTransactionRepository(ref.watch(secureStoreProvider)),
    );
final localLifecycleRepositoryProvider = Provider<LocalLifecycleRepository>(
  (ref) => LocalLifecycleRepository(ref.watch(secureStoreProvider)),
);
final pairingQrParserProvider = Provider<PairingQrParser>(
  (ref) => PairingQrParser(
    expectedEnvironment: ref.watch(environmentProvider).pairingEnvironment,
  ),
);
final pairingApiProvider = Provider<PairingApi>(
  (ref) => GeneratedPairingApi(
    StaffDevicePairingClient(ref.watch(publicDioProvider)),
    ref.watch(apiErrorDecoderProvider),
  ),
);
final metadataProvider = Provider<DeviceMetadataProvider>(
  (ref) => PlatformDeviceMetadataProvider(),
);
final pairingScannerAdapterProvider =
    Provider.autoDispose<PairingScannerAdapter>((ref) {
      final adapter = MobilePairingScannerAdapter();
      ref.onDispose(() => unawaited(adapter.dispose()));
      return adapter;
    });
final requestSignerProvider = Provider<DeviceRequestSigner>(
  (ref) => DeviceRequestSigner(ref.watch(identityRepositoryProvider)),
);
final deviceSessionApiProvider = Provider<DeviceSessionApi>(
  (ref) => SignedDeviceApi(
    ref.watch(signedDioProvider),
    ref.watch(requestSignerProvider),
    ref.watch(apiErrorDecoderProvider),
  ),
);
final sessionManagerProvider = Provider<SessionManager>(
  (ref) => SessionManager(
    ref.watch(sessionRepositoryProvider),
    ref.watch(deviceSessionApiProvider),
    ref.watch(identityRepositoryProvider),
    ref.watch(preferencesRepositoryProvider),
    lifecycleRepository: ref.watch(localLifecycleRepositoryProvider),
    transactionRepository: ref.watch(pairingTransactionRepositoryProvider),
  ),
);
final pairingFlowServiceProvider = Provider<PairingFlowService>(
  (ref) => PairingFlowService(
    ref.watch(pairingQrParserProvider),
    ref.watch(identityRepositoryProvider),
    ref.watch(pairingApiProvider),
    ref.watch(metadataProvider),
    ref.watch(sessionRepositoryProvider),
    ref.watch(pairingTransactionRepositoryProvider),
    ref.watch(localLifecycleRepositoryProvider),
    ref.watch(sessionManagerProvider),
  ),
);
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  await for (final results in connectivity.onConnectivityChanged) {
    yield online(results);
  }
});
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

final bootControllerProvider = NotifierProvider<BootController, BootState>(
  BootController.new,
);
final pairingControllerProvider =
    NotifierProvider<PairingController, PairingViewState>(
      PairingController.new,
    );
final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
