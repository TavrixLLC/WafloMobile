import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';

/// Canonical locales exposed by Waflo Staff.
abstract final class WafloLocales {
  static const english = Locale('en');
  static const arabic = Locale('ar');
  static const sorani = Locale('ckb');
  static const badini = Locale.fromSubtags(
    languageCode: 'ku',
    scriptCode: 'Arab',
    countryCode: 'IQ',
  );

  static const selectable = <Locale>[english, arabic, badini, sorani];

  static bool isKurdish(Locale locale) =>
      locale.languageCode == sorani.languageCode ||
      locale.languageCode == badini.languageCode;

  static bool usesArabicScript(Locale locale) =>
      locale.languageCode == arabic.languageCode || isKurdish(locale);

  static bool same(Locale first, Locale second) =>
      first.toLanguageTag() == second.toLanguageTag();

  static Locale? fromStoredTag(String? value) {
    return switch (value?.replaceAll('_', '-').toLowerCase()) {
      'en' => english,
      'ar' => arabic,
      'ckb' || 'ckb-arab-iq' => sorani,
      'ku-arab-iq' => badini,
      _ => null,
    };
  }
}

/// Flutter does not currently bundle Kurdish Material/Cupertino strings.
/// Waflo strings remain fully localized; Arabic supplies the closest framework
/// chrome while the custom Widgets delegate guarantees Arabic-script RTL.
const wafloLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  _KurdishMaterialLocalizationsDelegate(),
  _KurdishCupertinoLocalizationsDelegate(),
  _KurdishWidgetsLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

final class _KurdishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => WafloLocales.isKurdish(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(WafloLocales.arabic);

  @override
  bool shouldReload(_KurdishMaterialLocalizationsDelegate old) => false;
}

final class _KurdishCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KurdishCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => WafloLocales.isKurdish(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(WafloLocales.arabic);

  @override
  bool shouldReload(_KurdishCupertinoLocalizationsDelegate old) => false;
}

final class _KurdishWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _KurdishWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => WafloLocales.isKurdish(locale);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(WafloLocales.arabic);

  @override
  bool shouldReload(_KurdishWidgetsLocalizationsDelegate old) => false;
}
