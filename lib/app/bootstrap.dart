import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/app.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';

Future<void> bootstrap({
  AppFlavor? expectedNativeFlavor,
  AppEnvironment? environment,
  SharedPreferences? preferences,
  SecureKeyValueStore? secureStore,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final resolvedPreferences =
      preferences ?? await SharedPreferences.getInstance();
  final resolvedEnvironment =
      environment ??
      AppEnvironment.fromDefines(expectedNativeFlavor: expectedNativeFlavor);
  runApp(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(resolvedEnvironment),
        sharedPreferencesProvider.overrideWithValue(resolvedPreferences),
        if (secureStore != null)
          secureStoreProvider.overrideWithValue(secureStore),
      ],
      child: const WafloApp(),
    ),
  );
}
