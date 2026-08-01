import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';

final class PlatformDeviceMetadataProvider implements DeviceMetadataProvider {
  PlatformDeviceMetadataProvider({
    DeviceInfoPlugin? deviceInfo,
    Future<PackageInfo> Function()? packageInfoLoader,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform;

  final DeviceInfoPlugin _deviceInfo;
  final Future<PackageInfo> Function() _packageInfoLoader;

  @override
  Future<SafeDeviceMetadata> load() async {
    final package = await _packageInfoLoader();
    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      return SafeDeviceMetadata(
        platform: StaffMobilePlatform.android,
        appVersion: package.version,
        osVersion: android.version.release,
        model: android.model,
      );
    }
    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      return SafeDeviceMetadata(
        platform: StaffMobilePlatform.ios,
        appVersion: package.version,
        osVersion: ios.systemVersion,
        model: ios.utsname.machine,
      );
    }
    throw const ConfigurationFailure(['UNSUPPORTED_PLATFORM']);
  }
}
