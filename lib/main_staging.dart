import 'package:flutter/foundation.dart';
import 'package:waflo_staff/app/bootstrap.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_debug_bootstrap.dart';

Future<void> main() => bootstrap(
  expectedNativeFlavor: AppFlavor.staging,
  localDemo: kDebugMode ? buildLocalDemoDebugOverrides() : null,
);
