import 'package:flutter/material.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';

/// Official Waflo brand tokens from Developer/waflo-design-tokens.json.
abstract final class WafloColors {
  static const brick = Color(0xFFAE3115);
  static const coral = Color(0xFFFF6B4A);
  static const ember = Color(0xFF7D2311);
  static const ink = Color(0xFF241916);
  static const softCoral = Color(0xFFFFF0EC);
  static const cloud = Color(0xFFF7F9FF);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF76645F);
  static const success = Color(0xFF1F8F6A);
  static const warning = Color(0xFFE6A23C);
  static const danger = Color(0xFFC93C2B);

  // Direction A+ semantic dark surfaces. Official brand colors above remain
  // unchanged; these neutrals only define the selected dark presentation.
  static const darkCanvas = Color(0xFF14100F);
  static const darkSurface = Color(0xFF1E1817);
  static const darkElevated = Color(0xFF2A201D);
  static const darkOutline = Color(0xFF362C29);
  static const scannerOverlay = Color(0xD9241916);

  static const seed = brick;
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

abstract final class WafloMotion {
  static const immediate = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 260);
  static const deliberate = Duration(milliseconds: 280);
  static const scannerBeam = Duration(milliseconds: 2300);
}

abstract final class WafloLayout {
  static const pageGutter = 20.0;
  static const tabletPageGutter = 32.0;
  static const compactBreakpoint = 600.0;
  static const wideBreakpoint = 900.0;
  static const maximumContentWidth = 680.0;
  static const maximumFormWidth = 560.0;
  static const maximumPinWidth = 484.0;
  static const maximumWideContentWidth = 1040.0;
  static const minimumTouchTarget = 48.0;
}

extension WafloResponsiveContext on BuildContext {
  /// Uses the shortest side so a landscape phone keeps the compact UI while
  /// tablets and large foldable panes receive the roomier layout.
  bool get isWafloTablet =>
      MediaQuery.sizeOf(this).shortestSide >= WafloLayout.compactBreakpoint;

  double wafloPageGutter({double compact = WafloLayout.pageGutter}) =>
      isWafloTablet ? WafloLayout.tabletPageGutter : compact;
}

/// Official Waflo radii.
abstract final class WafloRadius {
  static const small = 8.0;
  static const medium = 14.0;
  static const large = 22.0;
  static const extraLarge = 32.0;
  static const pill = 999.0;

  // Semantic compatibility aliases; every value maps to the official scale.
  static const compact = medium;
  static const button = medium;
  static const card = large;
  static const stage = extraLarge;
}

@immutable
final class WafloPalette extends ThemeExtension<WafloPalette> {
  const WafloPalette({
    required this.canvas,
    required this.brandAction,
    required this.onBrandAction,
    required this.successSurface,
    required this.onSuccessSurface,
    required this.warningSurface,
    required this.onWarningSurface,
    required this.dangerSurface,
    required this.onDangerSurface,
    required this.subtleText,
    required this.cardShadow,
  });

  final Color canvas;
  final Color brandAction;
  final Color onBrandAction;
  final Color successSurface;
  final Color onSuccessSurface;
  final Color warningSurface;
  final Color onWarningSurface;
  final Color dangerSurface;
  final Color onDangerSurface;
  final Color subtleText;
  final Color cardShadow;

  @override
  WafloPalette copyWith({
    Color? canvas,
    Color? brandAction,
    Color? onBrandAction,
    Color? successSurface,
    Color? onSuccessSurface,
    Color? warningSurface,
    Color? onWarningSurface,
    Color? dangerSurface,
    Color? onDangerSurface,
    Color? subtleText,
    Color? cardShadow,
  }) => WafloPalette(
    canvas: canvas ?? this.canvas,
    brandAction: brandAction ?? this.brandAction,
    onBrandAction: onBrandAction ?? this.onBrandAction,
    successSurface: successSurface ?? this.successSurface,
    onSuccessSurface: onSuccessSurface ?? this.onSuccessSurface,
    warningSurface: warningSurface ?? this.warningSurface,
    onWarningSurface: onWarningSurface ?? this.onWarningSurface,
    dangerSurface: dangerSurface ?? this.dangerSurface,
    onDangerSurface: onDangerSurface ?? this.onDangerSurface,
    subtleText: subtleText ?? this.subtleText,
    cardShadow: cardShadow ?? this.cardShadow,
  );

  @override
  WafloPalette lerp(covariant WafloPalette? other, double t) {
    if (other == null) return this;
    return WafloPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      brandAction: Color.lerp(brandAction, other.brandAction, t)!,
      onBrandAction: Color.lerp(onBrandAction, other.onBrandAction, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      onSuccessSurface: Color.lerp(
        onSuccessSurface,
        other.onSuccessSurface,
        t,
      )!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      onWarningSurface: Color.lerp(
        onWarningSurface,
        other.onWarningSurface,
        t,
      )!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      onDangerSurface: Color.lerp(onDangerSurface, other.onDangerSurface, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

extension WafloThemeContext on BuildContext {
  /// Safe even in emergency rendering paths outside an application theme.
  WafloPalette get waflo {
    final theme = Theme.of(this);
    return theme.extension<WafloPalette>() ??
        WafloTheme.palette(theme.brightness);
  }
}

abstract final class WafloTheme {
  static ThemeData light({Locale locale = const Locale('en')}) =>
      _build(Brightness.light, locale: locale);
  static ThemeData dark({Locale locale = const Locale('en')}) =>
      _build(Brightness.dark, locale: locale);

  static WafloPalette palette(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const WafloPalette(
        canvas: WafloColors.darkCanvas,
        brandAction: WafloColors.coral,
        onBrandAction: WafloColors.ink,
        successSurface: Color(0xFF163B30),
        onSuccessSurface: Color(0xFFC7F2E2),
        warningSurface: Color(0xFF3B2A16),
        onWarningSurface: Color(0xFFFFE1AB),
        dangerSurface: Color(0xFF43201B),
        onDangerSurface: Color(0xFFFFDAD1),
        subtleText: Color(0xFFC8B8B3),
        cardShadow: Color(0x33000000),
      );
    }
    return const WafloPalette(
      canvas: WafloColors.cloud,
      brandAction: WafloColors.brick,
      onBrandAction: WafloColors.white,
      successSurface: Color(0xFFE7F5EF),
      onSuccessSurface: Color(0xFF145A43),
      warningSurface: Color(0xFFFFF4DE),
      onWarningSurface: Color(0xFF664100),
      dangerSurface: Color(0xFFFFE9E4),
      onDangerSurface: Color(0xFF7D1E13),
      subtleText: WafloColors.muted,
      cardShadow: Color(0x1A241916),
    );
  }

  static ThemeData _build(Brightness brightness, {required Locale locale}) {
    final dark = brightness == Brightness.dark;
    final usesArabicTypography = WafloLocales.usesArabicScript(locale);
    final primaryFontFamily = usesArabicTypography
        ? 'NotoSansArabic'
        : 'Manrope';
    final fallbackFontFamilies = usesArabicTypography
        ? const ['Manrope']
        : const ['NotoSansArabic'];
    final scheme = dark
        ? const ColorScheme.dark(
            primary: WafloColors.coral,
            onPrimary: WafloColors.ink,
            primaryContainer: Color(0xFF5A241A),
            onPrimaryContainer: Color(0xFFFFD9D0),
            secondary: Color(0xFFFFB5A4),
            onSecondary: WafloColors.ink,
            surface: WafloColors.darkSurface,
            onSurface: Color(0xFFFFF4F1),
            surfaceContainerLow: WafloColors.darkSurface,
            surfaceContainer: WafloColors.darkElevated,
            outline: Color(0xFF9A827C),
            outlineVariant: WafloColors.darkOutline,
            error: Color(0xFFFFB4A8),
            onError: Color(0xFF690002),
          )
        : const ColorScheme.light(
            primary: WafloColors.brick,
            onPrimary: WafloColors.white,
            primaryContainer: WafloColors.softCoral,
            onPrimaryContainer: WafloColors.ember,
            secondary: WafloColors.coral,
            onSecondary: WafloColors.ink,
            surface: WafloColors.white,
            onSurface: WafloColors.ink,
            surfaceContainerLow: WafloColors.white,
            surfaceContainer: Color(0xFFF2F1F5),
            outline: Color(0xFF8A7771),
            outlineVariant: Color(0xFFE3DAD7),
            error: WafloColors.danger,
            onError: WafloColors.white,
          );
    final baseText = ThemeData(
      brightness: brightness,
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fallbackFontFamilies,
    ).textTheme;
    final textTheme = baseText
        .copyWith(
          displaySmall: baseText.displaySmall?.copyWith(
            fontSize: 44,
            height: 52 / 44,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
          headlineMedium: baseText.headlineMedium?.copyWith(
            fontSize: 32,
            height: 39 / 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          headlineSmall: baseText.headlineSmall?.copyWith(
            fontSize: 24,
            height: 31 / 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: baseText.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
          titleMedium: baseText.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          labelLarge: baseText.labelLarge?.copyWith(
            fontSize: 16,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
          labelMedium: baseText.labelMedium?.copyWith(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: baseText.bodyLarge?.copyWith(
            fontSize: 17,
            height: 26 / 17,
          ),
          bodyMedium: baseText.bodyMedium?.copyWith(height: 1.5),
          bodySmall: baseText.bodySmall?.copyWith(
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final resolvedPalette = palette(brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fallbackFontFamilies,
      colorScheme: scheme,
      extensions: [resolvedPalette],
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: resolvedPalette.canvas,
      canvasColor: resolvedPalette.canvas,
      splashFactory: InkRipple.splashFactory,
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
          borderRadius: BorderRadius.circular(WafloRadius.large),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(56, 56)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.surfaceContainer;
            }
            if (states.contains(WidgetState.pressed)) {
              return WafloColors.ember;
            }
            return WafloColors.brick;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurfaceVariant
                : WafloColors.white,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WafloRadius.large),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, 56),
          textStyle: textTheme.labelLarge,
          foregroundColor: dark ? const Color(0xFFFFC1B2) : WafloColors.brick,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WafloRadius.large),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
          foregroundColor: dark ? const Color(0xFFFFC1B2) : WafloColors.brick,
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
          borderRadius: BorderRadius.circular(WafloRadius.medium),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.medium),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.medium),
          borderSide: const BorderSide(color: WafloColors.brick, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        constraints: const BoxConstraints(maxWidth: 560),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        constraints: const BoxConstraints(maxWidth: 680),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(WafloRadius.extraLarge),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: WafloColors.brick,
        linearTrackColor: WafloColors.softCoral,
      ),
    );
  }
}
