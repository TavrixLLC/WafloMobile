import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';

void main() {
  test('Kurdish locale identifiers are canonical and Arabic-script', () {
    expect(WafloLocales.sorani.toLanguageTag(), 'ckb');
    expect(WafloLocales.badini.toLanguageTag(), 'ku-Arab-IQ');
    expect(WafloLocales.usesArabicScript(WafloLocales.sorani), isTrue);
    expect(WafloLocales.usesArabicScript(WafloLocales.badini), isTrue);
  });

  test('all localization catalogs are complete and placeholder-compatible', () {
    final template = _readCatalog('app_en.arb');
    final templateKeys = _messageKeys(template);

    for (final name in ['app_ar.arb', 'app_ckb.arb', 'app_ku.arb']) {
      final localized = _readCatalog(name);
      final localizedKeys = _messageKeys(localized);
      expect(
        localizedKeys,
        templateKeys,
        reason: '$name must translate all keys',
      );

      for (final key in templateKeys) {
        final value = localized[key];
        expect(value, isA<String>(), reason: '$name:$key must be text');
        final text = value! as String;
        expect(text.trim(), isNotEmpty, reason: '$name:$key must not be empty');
        expect(
          text,
          isNot(contains('\uFFFD')),
          reason: '$name:$key contains an invalid replacement character',
        );
        expect(
          _placeholders(text),
          _placeholders(template[key]! as String),
          reason: '$name:$key must preserve placeholders',
        );
      }
    }
  });
}

Map<String, Object?> _readCatalog(String name) =>
    jsonDecode(File('lib/core/localization/l10n/$name').readAsStringSync())
        as Map<String, Object?>;

Set<String> _messageKeys(Map<String, Object?> catalog) =>
    catalog.keys.where((key) => !key.startsWith('@')).toSet();

Set<String> _placeholders(String message) => RegExp(
  r'\{([A-Za-z][A-Za-z0-9_]*)(?:,|\})',
).allMatches(message).map((match) => match.group(1)!).toSet();
