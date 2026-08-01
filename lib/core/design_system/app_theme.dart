import 'package:flutter/material.dart';

abstract final class WafloColors {
  static const seed = Color(0xFF167A57);
  static const success = Color(0xFF1B7F5B);
  static const warning = Color(0xFF9A6700);
  static const danger = Color(0xFFB42318);
  static const ink = Color(0xFF10231B);
}

abstract final class WafloSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class WafloRadius {
  static const card = 20.0;
  static const button = 16.0;
}

abstract final class WafloTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: WafloColors.seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'WafloSans',
      fontFamilyFallback: const ['WafloArabic'],
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WafloRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WafloRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WafloRadius.button),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.button),
        ),
      ),
    );
  }
}
