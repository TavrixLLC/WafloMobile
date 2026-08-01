import 'dart:developer' as developer;

import 'package:waflo_staff/app/environment.dart';

abstract interface class SafeLogSink {
  void write(String message);
}

final class DeveloperLogSink implements SafeLogSink {
  const DeveloperLogSink();

  @override
  void write(String message) {
    developer.log(message, name: 'waflo.mobile');
  }
}

final class SensitiveRedactor {
  const SensitiveRedactor();

  static final RegExp _authorization = RegExp(
    r'(authorization\s*[:=]\s*device\s+)[^\s,}]+',
    caseSensitive: false,
  );
  static final RegExp _pairingToken = RegExp(
    r'waflo-pair-v1\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+',
  );
  static final RegExp _sensitiveJson = RegExp(
    r'("?(?:accessToken|refreshToken|pairingToken|privateKey|publicKey|signature|nonce|challenge|secret)"?\s*[:=]\s*")([^"]+)(")',
    caseSensitive: false,
  );

  String redact(String value) => value
      .replaceAllMapped(
        _authorization,
        (match) => '${match.group(1)}[REDACTED]',
      )
      .replaceAll(_pairingToken, '[REDACTED_PAIRING]')
      .replaceAllMapped(
        _sensitiveJson,
        (match) => '${match.group(1)}[REDACTED]${match.group(3)}',
      );
}

final class SafeLogger {
  SafeLogger(
    this._level, {
    SafeLogSink sink = const DeveloperLogSink(),
    SensitiveRedactor redactor = const SensitiveRedactor(),
  }) : // Public named parameters intentionally initialize private fields.
       // ignore: prefer_initializing_formals
       _sink = sink,
       // ignore: prefer_initializing_formals
       _redactor = redactor;

  static const Set<String> _allowedFields = {
    'appVersion',
    'environment',
    'errorCode',
    'requestId',
    'routeCategory',
    'deviceStatus',
    'durationMs',
    'connectivity',
  };

  final AppLogLevel _level;
  final SafeLogSink _sink;
  final SensitiveRedactor _redactor;

  void event(String name, {Map<String, Object?> fields = const {}}) {
    if (_level == AppLogLevel.minimal && !name.endsWith('.failed')) {
      return;
    }
    final safe = <String, Object?>{
      for (final entry in fields.entries)
        if (_allowedFields.contains(entry.key)) entry.key: entry.value,
    };
    _sink.write(_redactor.redact('$name $safe'));
  }
}
