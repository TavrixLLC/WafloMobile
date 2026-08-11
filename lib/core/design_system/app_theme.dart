import 'package:flutter/material.dart';

abstract final class WafloColors {
  static const counterPine = Color(0xFF075E46);
  static const deepCounter = Color(0xFF103A2F);
  static const freshMint = Color(0xFFDFF3EA);
  static const receipt = Color(0xFFF7F5EF);
  static const signalAmber = Color(0xFFA85D00);
  static const sealRed = Color(0xFFB3261E);
  static const ink = Color(0xFF17241F);
  static const night = Color(0xFF0D1814);
  static const nightSurface = Color(0xFF15251F);
  static const nightElevated = Color(0xFF1C3028);

  // Stable compatibility aliases used by pre-M3A presentation code.
  static const seed = counterPine;
  static const success = counterPine;
  static const warning = signalAmber;
  static const danger = sealRed;
}

abstract final class WafloSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class WafloRadius {
  static const compact = 12.0;
  static const button = 16.0;
  static const card = 20.0;
  static const stage = 28.0;
}

@immutable
final class WafloPalette extends ThemeExtension<WafloPalette> {
  const WafloPalette({
    required this.canvas,
    required this.counter,
    required this.onCounter,
    required this.readySurface,
    required this.onReadySurface,
    required this.warningSurface,
    required this.onWarningSurface,
    required this.dangerSurface,
    required this.onDangerSurface,
    required this.subtleInk,
  });

  final Color canvas;
  final Color counter;
  final Color onCounter;
  final Color readySurface;
  final Color onReadySurface;
  final Color warningSurface;
  final Color onWarningSurface;
  final Color dangerSurface;
  final Color onDangerSurface;
  final Color subtleInk;

  @override
  WafloPalette copyWith({
    Color? canvas,
    Color? counter,
    Color? onCounter,
    Color? readySurface,
    Color? onReadySurface,
    Color? warningSurface,
    Color? onWarningSurface,
    Color? dangerSurface,
    Color? onDangerSurface,
    Color? subtleInk,
  }) => WafloPalette(
    canvas: canvas ?? this.canvas,
    counter: counter ?? this.counter,
    onCounter: onCounter ?? this.onCounter,
    readySurface: readySurface ?? this.readySurface,
    onReadySurface: onReadySurface ?? this.onReadySurface,
    warningSurface: warningSurface ?? this.warningSurface,
    onWarningSurface: onWarningSurface ?? this.onWarningSurface,
    dangerSurface: dangerSurface ?? this.dangerSurface,
    onDangerSurface: onDangerSurface ?? this.onDangerSurface,
    subtleInk: subtleInk ?? this.subtleInk,
  );

  @override
  WafloPalette lerp(covariant WafloPalette? other, double t) {
    if (other == null) return this;
    return WafloPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      counter: Color.lerp(counter, other.counter, t)!,
      onCounter: Color.lerp(onCounter, other.onCounter, t)!,
      readySurface: Color.lerp(readySurface, other.readySurface, t)!,
      onReadySurface: Color.lerp(onReadySurface, other.onReadySurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      onWarningSurface: Color.lerp(
        onWarningSurface,
        other.onWarningSurface,
        t,
      )!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      onDangerSurface: Color.lerp(onDangerSurface, other.onDangerSurface, t)!,
      subtleInk: Color.lerp(subtleInk, other.subtleInk, t)!,
    );
  }
}

extension WafloThemeContext on BuildContext {
  WafloPalette get waflo => Theme.of(this).extension<WafloPalette>()!;
}

abstract final class WafloTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = dark
        ? const ColorScheme.dark(
            primary: Color(0xFF8AD9BD),
            onPrimary: WafloColors.deepCounter,
            primaryContainer: Color(0xFF174B3C),
            onPrimaryContainer: Color(0xFFD7F8EA),
            secondary: Color(0xFFC0D9CF),
            onSecondary: Color(0xFF243B32),
            surface: WafloColors.night,
            onSurface: Color(0xFFE5ECE8),
            surfaceContainerLow: WafloColors.nightSurface,
            surfaceContainer: WafloColors.nightElevated,
            outline: Color(0xFF73877E),
            outlineVariant: Color(0xFF35483F),
            error: Color(0xFFFFB4AB),
            onError: Color(0xFF690005),
          )
        : const ColorScheme.light(
            primary: WafloColors.counterPine,
            onPrimary: Colors.white,
            primaryContainer: WafloColors.freshMint,
            onPrimaryContainer: WafloColors.deepCounter,
            secondary: Color(0xFF4D635A),
            onSecondary: Colors.white,
            surface: WafloColors.receipt,
            onSurface: WafloColors.ink,
            surfaceContainerLow: Color(0xFFFBFAF6),
            surfaceContainer: Color(0xFFF0F1EC),
            outline: Color(0xFF6C7B74),
            outlineVariant: Color(0xFFCCD6D0),
            error: WafloColors.sealRed,
            onError: Colors.white,
          );
    final baseText = ThemeData(brightness: brightness).textTheme;
    final textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        height: 1.05,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
        height: 1.1,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.15,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      labelMedium: baseText.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.55,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.4),
    );
    final palette = dark
        ? const WafloPalette(
            canvas: WafloColors.night,
            counter: Color(0xFF8AD9BD),
            onCounter: WafloColors.deepCounter,
            readySurface: Color(0xFF173E33),
            onReadySurface: Color(0xFFCFF6E6),
            warningSurface: Color(0xFF3D2D16),
            onWarningSurface: Color(0xFFFFDDAA),
            dangerSurface: Color(0xFF3C2020),
            onDangerSurface: Color(0xFFFFDAD6),
            subtleInk: Color(0xFFACBBB4),
          )
        : const WafloPalette(
            canvas: WafloColors.receipt,
            counter: WafloColors.counterPine,
            onCounter: Colors.white,
            readySurface: WafloColors.freshMint,
            onReadySurface: WafloColors.deepCounter,
            warningSurface: Color(0xFFFFEBCB),
            onWarningSurface: Color(0xFF4A2A00),
            dangerSurface: Color(0xFFFFDAD6),
            onDangerSurface: Color(0xFF5D0003),
            subtleInk: Color(0xFF586861),
          );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'WafloSans',
      fontFamilyFallback: const ['WafloArabic'],
      colorScheme: scheme,
      extensions: [palette],
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WafloRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WafloRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, 56),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WafloRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size.square(48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.button),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.button),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WafloRadius.stage),
        ),
      ),
    );
  }
}
