import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/app_lifecycle.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/app/router.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';

final class WafloApp extends ConsumerWidget {
  const WafloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final typographyLocale =
        locale ?? WidgetsBinding.instance.platformDispatcher.locale;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: WafloTheme.light(locale: typographyLocale),
      darkTheme: WafloTheme.dark(locale: typographyLocale),
      themeMode: themeMode,
      builder: (context, child) =>
          AppLifecycleBoundary(child: child ?? const SizedBox.shrink()),
    );
  }
}
