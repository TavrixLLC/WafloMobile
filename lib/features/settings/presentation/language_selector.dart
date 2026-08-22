import 'package:flutter/material.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';

final class WafloLanguageSelector extends StatelessWidget {
  const WafloLanguageSelector({
    required this.selectedLocale,
    required this.onSelected,
    super.key,
  });

  final Locale selectedLocale;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final resolvedLocale = WafloLocales.selectable.firstWhere(
      (locale) => WafloLocales.same(locale, selectedLocale),
      orElse: () => WafloLocales.english,
    );
    return WafloSelectField<Locale>(
      key: ValueKey('language-select-${resolvedLocale.toLanguageTag()}'),
      selectedValue: resolvedLocale,
      semanticsLabel: strings.chooseLanguage,
      icon: Icons.language_rounded,
      items: [
        DropdownMenuItem(
          key: const Key('language-en'),
          value: WafloLocales.english,
          child: Text(strings.english),
        ),
        DropdownMenuItem(
          key: const Key('language-ar'),
          value: WafloLocales.arabic,
          child: Text(strings.arabic),
        ),
        DropdownMenuItem<Locale>(
          key: const Key('language-kurdish-label'),
          enabled: false,
          child: Text(
            strings.kurdishGroup,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: context.waflo.subtleText),
          ),
        ),
        DropdownMenuItem(
          key: const Key('language-ku-Arab-IQ'),
          value: WafloLocales.badini,
          child: Text(strings.kurdishBadini),
        ),
        DropdownMenuItem(
          key: const Key('language-ckb'),
          value: WafloLocales.sorani,
          child: Text(strings.kurdishSorani),
        ),
      ],
      onSelected: onSelected,
    );
  }
}

final class WafloSelectField<T> extends StatelessWidget {
  const WafloSelectField({
    required this.selectedValue,
    required this.semanticsLabel,
    required this.icon,
    required this.items,
    required this.onSelected,
    super.key,
  });

  final T selectedValue;
  final String semanticsLabel;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticsLabel,
    child: DropdownButtonFormField<T>(
      initialValue: selectedValue,
      isExpanded: true,
      menuMaxHeight: 360,
      borderRadius: BorderRadius.circular(WafloRadius.large),
      dropdownColor: Theme.of(context).colorScheme.surface,
      icon: Icon(Icons.expand_more_rounded, color: context.waflo.subtleText),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        prefixIcon: Icon(icon, color: context.waflo.brandAction, size: 21),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 6, 10, 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.medium),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.medium),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WafloRadius.medium),
          borderSide: BorderSide(color: context.waflo.brandAction, width: 1.5),
        ),
      ),
      items: items,
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    ),
  );
}
