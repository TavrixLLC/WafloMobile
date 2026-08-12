import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';

void main() {
  test('official Waflo source tokens remain exact', () {
    expect(WafloColors.brick, const Color(0xFFAE3115));
    expect(WafloColors.coral, const Color(0xFFFF6B4A));
    expect(WafloColors.ember, const Color(0xFF7D2311));
    expect(WafloColors.ink, const Color(0xFF241916));
    expect(WafloColors.softCoral, const Color(0xFFFFF0EC));
    expect(WafloColors.cloud, const Color(0xFFF7F9FF));
    expect(WafloColors.muted, const Color(0xFF76645F));
    expect(WafloColors.success, const Color(0xFF1F8F6A));
    expect(WafloColors.warning, const Color(0xFFE6A23C));
    expect(WafloColors.danger, const Color(0xFFC93C2B));
    expect(WafloRadius.small, 8);
    expect(WafloRadius.medium, 14);
    expect(WafloRadius.large, 22);
    expect(WafloRadius.extraLarge, 32);
    expect(WafloRadius.pill, 999);
  });

  test('official brand assets and bundled fonts exist', () {
    for (final path in <String>[
      'assets/brand/logo/waflo-mark-primary-512.png',
      'assets/brand/logo/waflo-mark-white-1024.png',
      'assets/brand/logo/waflo-logo-primary-horizontal-1600.png',
      'assets/brand/logo/waflo-logo-white-horizontal-1600.png',
      'assets/brand/fonts/Manrope-Regular.ttf',
      'assets/brand/fonts/Manrope-Medium.ttf',
      'assets/brand/fonts/Manrope-SemiBold.ttf',
      'assets/brand/fonts/Manrope-Bold.ttf',
      'assets/brand/fonts/Manrope-ExtraBold.ttf',
      'assets/brand/fonts/NotoSansArabic-Variable.ttf',
      'assets/brand/fonts/Manrope-OFL.txt',
      'assets/brand/fonts/NotoSansArabic-OFL.txt',
      'assets/brand/fonts/LICENSE-NOTES.txt',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  testWidgets('theme uses official typography and safe palette fallback', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(context.waflo.brandAction, WafloColors.brick);
    expect(WafloTheme.light().textTheme.bodyLarge?.fontFamily, 'Manrope');
    expect(
      WafloTheme.light().textTheme.bodyLarge?.fontFamilyFallback,
      contains('NotoSansArabic'),
    );
    final arabicTheme = WafloTheme.light(locale: const Locale('ar'));
    expect(arabicTheme.textTheme.bodyLarge?.fontFamily, 'NotoSansArabic');
    expect(
      arabicTheme.textTheme.bodyLarge?.fontFamilyFallback,
      contains('Manrope'),
    );
  });
}
