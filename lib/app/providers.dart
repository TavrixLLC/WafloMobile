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
import 'package:waflo_staff/core/haptics/haptic_service.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/core/logging/safe_logger.dart';
import 'package:waflo_staff/core/network/dio_factory.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/app_lock/data/biometric_service.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_controller.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/pairing/data/generated_pairing_api.dart';
import 'package:waflo_staff/features/pairing/data/platform_device_metadata.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/settings/presentation/preferences_controllers.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

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
final appLockRepositoryProvider = Provider<AppLockRepository>(
  (ref) => AppLockRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(secureStoreProvider),
  ),
);
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => PlatformBiometricService(),
);
final hapticServiceProvider = Provider<HapticService>(
  (ref) => const PlatformHapticService(),
);
final pendingOperationStoreProvider = Provider<PendingOperationStore>(
  (ref) => SharedPreferencesPendingOperationStore(
    ref.watch(sharedPreferencesProvider),
  ),
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
final stampAssetDioProvider = Provider<Dio>(
  (ref) => const DioFactory().create(ref.watch(environmentProvider)),
);
final stampImageCacheProvider = Provider<StampImageLoader>(
  (ref) => DigestImageCache(ref.watch(stampAssetDioProvider)),
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
final customerScannerAdapterProvider =
    Provider.autoDispose<CustomerScannerAdapter>((ref) {
      final adapter = MobileCustomerScannerAdapter();
      ref.onDispose(() => unawaited(adapter.dispose()));
      return adapter;
    });
final requestSignerProvider = Provider<DeviceRequestSigner>(
  (ref) => DeviceRequestSigner(ref.watch(identityRepositoryProvider)),
);
final businessCommandIdGeneratorProvider = Provider<BusinessCommandIdGenerator>(
  (ref) => const UuidBusinessCommandIdGenerator(),
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
final loyaltyOperationsApiProvider = Provider<LoyaltyOperationsApi>(
  (ref) => SignedLoyaltyOperationsApi(
    dio: ref.watch(signedDioProvider),
    signer: ref.watch(requestSignerProvider),
    errorDecoder: ref.watch(apiErrorDecoderProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    refreshSession: ref.watch(sessionManagerProvider).refreshSingleFlight,
    allowInsecureAssets:
        ref.watch(environmentProvider).flavor == AppFlavor.development,
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
final m2OperationControllerProvider =
    NotifierProvider<M2OperationController, M2OperationState>(
      M2OperationController.new,
    );
final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
final rapidScanControllerProvider = NotifierProvider<RapidScanController, bool>(
  RapidScanController.new,
);
final appLockControllerProvider =
    NotifierProvider<AppLockController, AppLockState>(AppLockController.new);
