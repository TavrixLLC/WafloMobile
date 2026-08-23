import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';

/// A capability produced only after the local Review code has been verified.
/// It carries no Production identity, token, role, or backend permission.
final class LocalReviewAccessGrant {
  const LocalReviewAccessGrant._();
}

/// Formatting shared by the neutral manual pairing-code field and the local
/// verifier. The 12-character alphabet deliberately omits ambiguous symbols.
abstract final class LocalReviewCodeFormat {
  static String normalize(String value) {
    final compact = value.toUpperCase().replaceAll(
      RegExp('[^A-HJ-NP-Z2-9]'),
      '',
    );
    final bounded = compact.substring(0, compact.length.clamp(0, 12));
    final groups = <String>[];
    for (var start = 0; start < bounded.length; start += 4) {
      groups.add(
        bounded.substring(start, (start + 4).clamp(0, bounded.length)),
      );
    }
    return groups.join('-');
  }

  static bool isValid(String value) =>
      RegExp(r'^[A-HJ-NP-Z2-9]{4}(?:-[A-HJ-NP-Z2-9]{4}){2}$').hasMatch(value);
}

/// Local-only Review access authority.
///
/// The app contains only a SHA-256 digest of a domain-separated, high-entropy
/// Review code. Failed-attempt state and the non-secret active-mode marker are
/// persisted locally so restarting the app cannot bypass throttling.
final class LocalReviewAccess {
  LocalReviewAccess(
    this._preferences, {
    String expectedDigest = _buildDigest,
    DateTime Function()? now,
  }) : _expectedDigest = expectedDigest.toLowerCase(),
       _now = now ?? DateTime.now;

  static const _buildDigest = String.fromEnvironment(
    'WAFLO_REVIEW_CODE_DIGEST',
    defaultValue:
        'cfe79dd27fd04cd48d85da6335eb9541e61458dc29ce2005f3c4b518c054dd32',
  );
  static const _digestContext = 'waflo-local-review-access-v1\n';
  static const _failureCountKey = 'review_access.failure_count.v1';
  static const _failureWindowKey = 'review_access.failure_window.v1';
  static const _lockedUntilKey = 'review_access.locked_until.v1';
  static const _activeKey = 'review_mode.local_active.v1';
  static const _failureWindow = Duration(minutes: 15);
  static const _lockDuration = Duration(minutes: 15);
  static const _maximumFailures = 5;

  final SharedPreferences _preferences;
  final String _expectedDigest;
  final DateTime Function() _now;

  Future<LocalReviewAccessGrant> authorize(String rawCode) async {
    final now = _now().toUtc();
    final lockedUntil = _readDate(_lockedUntilKey);
    if (lockedUntil != null && lockedUntil.isAfter(now)) {
      throw const ApiFailure(
        'REVIEW_ACCESS_RATE_LIMITED',
        httpStatus: 429,
        responseReceived: false,
      );
    }
    if (lockedUntil != null) await _clearFailures();

    final normalized = LocalReviewCodeFormat.normalize(rawCode);
    final candidateDigest = sha256
        .convert(utf8.encode('$_digestContext$normalized'))
        .toString();
    final configured = RegExp(r'^[a-f0-9]{64}$').hasMatch(_expectedDigest);
    if (configured &&
        LocalReviewCodeFormat.isValid(normalized) &&
        _constantTimeEquals(candidateDigest, _expectedDigest)) {
      await _clearFailures();
      return const LocalReviewAccessGrant._();
    }

    await _registerFailure(now);
    throw const ApiFailure(
      'REVIEW_ACCESS_INVALID',
      httpStatus: 401,
      responseReceived: false,
    );
  }

  bool get isActive => _preferences.getBool(_activeKey) ?? false;

  Future<void> activate(LocalReviewAccessGrant grant) async {
    // Requiring the unforgeable grant type keeps activation behind authorize().
    await _preferences.setBool(_activeKey, true);
  }

  Future<void> deactivate() async {
    await _preferences.remove(_activeKey);
  }

  Future<void> _registerFailure(DateTime now) async {
    final windowStarted = _readDate(_failureWindowKey);
    final inWindow =
        windowStarted != null && now.difference(windowStarted) < _failureWindow;
    final failures = inWindow
        ? (_preferences.getInt(_failureCountKey) ?? 0) + 1
        : 1;
    await _preferences.setInt(_failureCountKey, failures);
    await _preferences.setString(
      _failureWindowKey,
      (inWindow ? windowStarted : now).toIso8601String(),
    );
    if (failures >= _maximumFailures) {
      await _preferences.setString(
        _lockedUntilKey,
        now.add(_lockDuration).toIso8601String(),
      );
    }
  }

  Future<void> _clearFailures() async {
    await _preferences.remove(_failureCountKey);
    await _preferences.remove(_failureWindowKey);
    await _preferences.remove(_lockedUntilKey);
  }

  DateTime? _readDate(String key) {
    final value = _preferences.getString(key);
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  static bool _constantTimeEquals(String candidate, String expected) {
    if (candidate.length != expected.length) return false;
    var difference = 0;
    for (var index = 0; index < candidate.length; index += 1) {
      difference |= candidate.codeUnitAt(index) ^ expected.codeUnitAt(index);
    }
    return difference == 0;
  }
}
