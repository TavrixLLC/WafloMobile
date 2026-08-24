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
import 'package:waflo_staff/core/network/review_mode_network_guard.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/core/permissions/camera_permission.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/app_lock/data/biometric_service.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_controller.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_debug.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_controller.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/pairing/data/generated_pairing_api.dart';
import 'package:waflo_staff/features/pairing/data/platform_device_metadata.dart';
import 'package:waflo_staff/features/pairing/domain/manual_code_router.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/review_access/data/local_review_scenarios_repository.dart';
import 'package:waflo_staff/features/review_access/domain/local_review_access.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';
import 'package:waflo_staff/features/review_access/presentation/review_access_controller.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';
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
final cameraPermissionCoordinatorProvider =
    Provider<CameraPermissionCoordinator>(
      (ref) => CameraPermissionCoordinator(
        const PermissionHandlerCameraPermissionGateway(),
      ),
    );
final safeLoggerProvider = Provider<SafeLogger>(
  (ref) => SafeLogger(ref.watch(environmentProvider).logLevel),
);
final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(sharedPreferencesProvider)),
);
final localReviewAccessProvider = Provider<LocalReviewAccess>(
  (ref) => LocalReviewAccess(ref.watch(sharedPreferencesProvider)),
);
final localDemoRuntimeProvider = Provider<LocalDemoRuntime>(
  (ref) => LocalDemoRuntimeDebug(forceAvailable: true),
);
final localDemoAccessAvailableProvider = Provider<bool>((ref) {
  try {
    return ref
        .watch(localDemoRuntimeProvider)
        .availableFor(ref.watch(environmentProvider));
  } on StateError {
    // Presentation-only widget tests that do not bootstrap an environment
    // must retain the server-backed Review credential path.
    return false;
  }
});
final appLockRepositoryProvider = Provider<AppLockStore>((ref) {
  if (ref.watch(localDemoControllerProvider.select((state) => state.active))) {
    return ref.watch(localDemoRuntimeProvider).appLock;
  }
  return AppLockRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(secureStoreProvider),
  );
});
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => PlatformBiometricService(),
);
final hapticServiceProvider = Provider<HapticService>(
  (ref) => const PlatformHapticService(),
);
final pendingOperationStoreProvider = Provider<PendingOperationStore>((ref) {
  if (ref.watch(localDemoControllerProvider.select((state) => state.active))) {
    return ref.watch(localDemoRuntimeProvider).pendingOperations;
  }
  return SharedPreferencesPendingOperationStore(
    ref.watch(sharedPreferencesProvider),
  );
});
final managerApprovalIntentStoreProvider = Provider<ManagerApprovalIntentStore>(
  (ref) {
    if (ref.watch(
      localDemoControllerProvider.select((state) => state.active),
    )) {
      return ref.watch(localDemoRuntimeProvider).managerApprovalIntents;
    }
    return SecureManagerApprovalIntentStore(ref.watch(secureStoreProvider));
  },
);
final apiErrorDecoderProvider = Provider<ApiErrorDecoder>(
  (ref) => const ApiErrorDecoder(),
);
final reviewModeNetworkGuardProvider = Provider<ReviewModeNetworkGuard>((ref) {
  final guard = ReviewModeNetworkGuard();
  ref.listen<bool>(
    localDemoControllerProvider.select((state) => state.active),
    (previous, active) => guard.setBlocked(active),
    fireImmediately: true,
  );
  return guard;
});
final publicDioProvider = Provider<Dio>((ref) {
  final dio = const DioFactory().create(ref.watch(environmentProvider));
  dio.interceptors.insert(
    0,
    ReviewModeNetworkInterceptor(ref.watch(reviewModeNetworkGuardProvider)),
  );
  return dio;
});
final signedDioProvider = Provider<Dio>((ref) {
  final dio = const DioFactory().create(ref.watch(environmentProvider));
  dio.interceptors.insert(
    0,
    ReviewModeNetworkInterceptor(ref.watch(reviewModeNetworkGuardProvider)),
  );
  return dio;
});
final stampAssetDioProvider = Provider<Dio>((ref) {
  final dio = const DioFactory().create(ref.watch(environmentProvider));
  dio.interceptors.insert(
    0,
    ReviewModeNetworkInterceptor(ref.watch(reviewModeNetworkGuardProvider)),
  );
  return dio;
});
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
final manualCodeIntentResolverProvider = Provider<ManualCodeIntentResolver>(
  (ref) => const ProductManualCodeIntentResolver(),
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
      final adapter = MobilePairingScannerAdapter(
        permissionCoordinator: ref.watch(cameraPermissionCoordinatorProvider),
      );
      ref.onDispose(() => unawaited(adapter.dispose()));
      return adapter;
    });
final customerScannerAdapterProvider =
    Provider.autoDispose<CustomerScannerAdapter>((ref) {
      if (ref.watch(
        localDemoControllerProvider.select((state) => state.active),
      )) {
        final adapter = ref
            .watch(localDemoRuntimeProvider)
            .createScannerAdapter();
        ref.onDispose(() => unawaited(adapter.dispose()));
        return adapter;
      }
      final adapter = MobileCustomerScannerAdapter(
        permissionCoordinator: ref.watch(cameraPermissionCoordinatorProvider),
      );
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
final loyaltyOperationsApiProvider = Provider<LoyaltyOperationsApi>((ref) {
  if (ref.watch(localDemoControllerProvider.select((state) => state.active))) {
    return ref.watch(localDemoRuntimeProvider).loyaltyOperations;
  }
  return SignedLoyaltyOperationsApi(
    dio: ref.watch(signedDioProvider),
    signer: ref.watch(requestSignerProvider),
    errorDecoder: ref.watch(apiErrorDecoderProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    refreshSession: ref.watch(sessionManagerProvider).refreshSingleFlight,
    allowInsecureAssets:
        ref.watch(environmentProvider).flavor == AppFlavor.development,
  );
});
final reviewAccessRepositoryProvider = Provider<ReviewAccessRepository>(
  (ref) => const LocalReviewScenariosRepository(),
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
final operationalOnlineProvider = Provider<bool>((ref) {
  if (ref.watch(localDemoControllerProvider.select((state) => state.active))) {
    return true;
  }
  return ref.watch(connectivityProvider).value ?? false;
});
final activeDeviceContextProvider = Provider<AuthoritativeDeviceContext?>((
  ref,
) {
  if (ref.watch(localDemoControllerProvider.select((state) => state.active))) {
    return ref.watch(localDemoRuntimeProvider).deviceContext;
  }
  return ref.watch(bootControllerProvider).context;
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
final reviewAccessControllerProvider =
    NotifierProvider<ReviewAccessController, ReviewToolsState>(
      ReviewAccessController.new,
    );
final localDemoControllerProvider =
    NotifierProvider<LocalDemoController, LocalDemoState>(
      LocalDemoController.new,
    );
