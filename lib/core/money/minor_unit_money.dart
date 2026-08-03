import 'package:intl/intl.dart';

final class MoneyInputException implements FormatException {
  const MoneyInputException(this.code);

  final String code;

  @override
  int? get offset => null;

  @override
  String get message => code;

  @override
  Object? get source => null;

  @override
  String toString() => 'MoneyInputException($code)';
}

final class CurrencyMetadata {
  const CurrencyMetadata._();

  static const _approvedOverrides = <String, int>{
    'BHD': 3,
    'IQD': 3,
    'JOD': 3,
    'KWD': 3,
    'OMR': 3,
    'TND': 3,
    'JPY': 0,
    'KRW': 0,
  };

  static int fractionDigits(String currencyCode) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw const MoneyInputException('PURCHASE_CURRENCY_INVALID');
    }
    final digits =
        _approvedOverrides[currencyCode] ??
        NumberFormat.currency(locale: 'en', name: currencyCode).decimalDigits ??
        2;
    if (digits < 0 || digits > 3) {
      throw const MoneyInputException('PURCHASE_CURRENCY_UNSUPPORTED');
    }
    return digits;
  }
}

final class MinorUnitMoney {
  const MinorUnitMoney({
    required this.minorUnits,
    required this.currencyCode,
    required this.fractionDigits,
  });

  final int minorUnits;
  final String currencyCode;
  final int fractionDigits;

  static MinorUnitMoney parse(String input, {required String currencyCode}) {
    final fractionDigits = CurrencyMetadata.fractionDigits(currencyCode);
    final normalized = _normalizeDigits(input.trim());
    if (normalized.isEmpty) {
      throw const MoneyInputException('PURCHASE_AMOUNT_REQUIRED');
    }
    if (normalized.contains(',') ||
        normalized.contains('\u066C') ||
        normalized.contains(' ') ||
        normalized.startsWith('+')) {
      throw const MoneyInputException('PURCHASE_GROUPING_AMBIGUOUS');
    }
    if (normalized.startsWith('-')) {
      throw const MoneyInputException('PURCHASE_AMOUNT_NEGATIVE');
    }
    final match = RegExp(r'^(\d+)(?:\.(\d*))?$').firstMatch(normalized);
    if (match == null) {
      throw const MoneyInputException('PURCHASE_AMOUNT_INVALID');
    }
    final fraction = match.group(2) ?? '';
    if (fraction.length > fractionDigits) {
      throw const MoneyInputException('PURCHASE_EXCESS_PRECISION');
    }
    final whole = int.tryParse(match.group(1)!);
    if (whole == null) {
      throw const MoneyInputException('PURCHASE_AMOUNT_TOO_LARGE');
    }
    final factor = _powerOfTen(fractionDigits);
    final fractionMinor = fraction.isEmpty
        ? 0
        : int.parse(fraction.padRight(fractionDigits, '0'));
    if (whole > (0x7FFFFFFFFFFFFFFF - fractionMinor) ~/ factor) {
      throw const MoneyInputException('PURCHASE_AMOUNT_TOO_LARGE');
    }
    return MinorUnitMoney(
      minorUnits: whole * factor + fractionMinor,
      currencyCode: currencyCode,
      fractionDigits: fractionDigits,
    );
  }

  String formatExact() {
    final factor = _powerOfTen(fractionDigits);
    final whole = minorUnits ~/ factor;
    if (fractionDigits == 0) {
      return '$whole $currencyCode';
    }
    final fraction = (minorUnits % factor).toString().padLeft(
      fractionDigits,
      '0',
    );
    return '$whole.$fraction $currencyCode';
  }

  static int _powerOfTen(int exponent) {
    var value = 1;
    for (var index = 0; index < exponent; index += 1) {
      value *= 10;
    }
    return value;
  }

  static String _normalizeDigits(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      final arabicIndex = arabic.indexOf(character);
      final persianIndex = persian.indexOf(character);
      if (arabicIndex >= 0) {
        buffer.write(arabicIndex);
      } else if (persianIndex >= 0) {
        buffer.write(persianIndex);
      } else if (character == '\u066B') {
        buffer.write('.');
      } else {
        buffer.write(character);
      }
    }
    return buffer.toString();
  }
}

final class MerchantTransactionReference {
  const MerchantTransactionReference._(this.value);

  final String value;

  static MerchantTransactionReference? parse(
    String input, {
    required bool allowed,
    required bool required,
  }) {
    final value = input.trim();
    if (value.isEmpty) {
      if (required) {
        throw const MoneyInputException('TRANSACTION_REFERENCE_REQUIRED');
      }
      return null;
    }
    if (!allowed) {
      throw const MoneyInputException('TRANSACTION_REFERENCE_NOT_ALLOWED');
    }
    if (value.length > 120 ||
        !RegExp(r'^[\p{L}\p{N}._:/ -]+$', unicode: true).hasMatch(value)) {
      throw const MoneyInputException('TRANSACTION_REFERENCE_INVALID');
    }
    if (RegExp(r'(?:\d[ -]?){13,19}').hasMatch(value)) {
      throw const MoneyInputException('TRANSACTION_REFERENCE_CARD_LIKE');
    }
    return MerchantTransactionReference._(value);
  }
}
