import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/api/generated_m2/models/stamp_request.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/localization/localization_extensions.dart';
import 'package:waflo_staff/core/logging/safe_logger.dart';
import 'package:waflo_staff/core/money/minor_unit_money.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';

void main() {
  group('approved M2 projection', () {
    test('validates membership and authoritative policy', () {
      final membership = ResolvedMembership.fromJson(
        _fixture('membership-resolve.fixture.json'),
        allowInsecureAssets: false,
      );

      expect(membership.progress.progress, 5);
      expect(membership.progress.goal, 8);
      expect(membership.operationPolicy.effectiveMaximumStampAmount, 3);
      expect(membership.operationPolicy.selectableMaximumStampAmount, 3);
      expect(
        membership.availableRewards.single.requiresManagerApproval,
        isFalse,
      );
    });

    test('rejects malformed progress and unknown enums', () {
      final progress = _fixture('membership-resolve.fixture.json');
      progress['progress'] = 9;
      expect(
        () => ResolvedMembership.fromJson(progress, allowInsecureAssets: false),
        throwsA(isA<FormatException>()),
      );

      final status = _fixture('membership-resolve.fixture.json');
      status['membershipStatus'] = 'FUTURE_STATE';
      expect(
        () => ResolvedMembership.fromJson(status, allowInsecureAssets: false),
        throwsA(isA<M2ContractViolation>()),
      );
    });

    test('two-state reducer has exact final and reset projections', () {
      expect(
        StampProgress.validated(progress: 8, goal: 8).slots,
        everyElement(StampSlotState.filled),
      );
      expect(
        StampProgress.validated(progress: 0, goal: 8).slots,
        everyElement(StampSlotState.empty),
      );
      expect(StampSlotState.values, hasLength(2));
    });

    test('maps committed stamp and final redemption fixtures', () {
      final stamp = StampOperationResult.fromJson(
        _fixture('stamp-final-ready.fixture.json'),
      );
      final redemption = RedemptionOperationResult.fromJson(
        _fixture('redeem-final-reset.fixture.json'),
      );

      expect(stamp.progress.progress, 8);
      expect(stamp.rewardReady, isTrue);
      expect(stamp.unlockedRewards.single.finalReward, isTrue);
      expect(redemption.finalReward, isTrue);
      expect(redemption.progress.progress, 0);
      expect(redemption.rewardReady, isFalse);
    });
  });

  group('minor-unit money and references', () {
    test('parses English and Arabic digits without floating point', () {
      expect(
        MinorUnitMoney.parse('12.34', currencyCode: 'USD').minorUnits,
        1234,
      );
      expect(
        MinorUnitMoney.parse('12.34', currencyCode: 'usd').currencyCode,
        'USD',
      );
      expect(
        MinorUnitMoney.parse('١٢٫٣٤٥', currencyCode: 'IQD').minorUnits,
        12345,
      );
    });

    test('purchase currency accepts only exactly three ASCII letters', () {
      expect(CurrencyMetadata.normalizeCode('IQD'), 'IQD');
      expect(CurrencyMetadata.normalizeCode('usd'), 'USD');
      for (final invalid in ['US', 'USDD', '12A', r'US$', 'Iraqi Dinar']) {
        expect(
          () => CurrencyMetadata.normalizeCode(invalid),
          throwsA(isA<MoneyInputException>()),
          reason: invalid,
        );
      }
    });

    test('generated request rejects object and array purchase currencies', () {
      const base = <String, Object?>{
        'qrPayload':
            'customer-membership-credential-fixture-000000000000000000000000',
        'amount': 1,
      };
      for (final invalid in [<String, Object?>{}, <Object?>[]]) {
        expect(
          () => StampRequest.fromJson({...base, 'purchaseCurrency': invalid}),
          throwsA(anything),
        );
      }
    });

    test(
      'rejects excess precision, grouping ambiguity, and card-like refs',
      () {
        expect(
          () => MinorUnitMoney.parse('1.001', currencyCode: 'USD'),
          throwsA(
            isA<MoneyInputException>().having(
              (error) => error.code,
              'code',
              'PURCHASE_EXCESS_PRECISION',
            ),
          ),
        );
        expect(
          () => MinorUnitMoney.parse('1,000', currencyCode: 'USD'),
          throwsA(isA<MoneyInputException>()),
        );
        expect(
          () => MerchantTransactionReference.parse(
            '4111 1111 1111 1111',
            allowed: true,
            required: false,
          ),
          throwsA(
            isA<MoneyInputException>().having(
              (error) => error.code,
              'code',
              'TRANSACTION_REFERENCE_CARD_LIKE',
            ),
          ),
        );
      },
    );
  });

  group('idempotency and pending recovery', () {
    test('fixed command IDs have a one-way lifecycle', () {
      final generator = FixedBusinessCommandIdGenerator(const [
        '20000000-0000-4000-8000-000000000001',
      ]);
      expect(generator.next(), '20000000-0000-4000-8000-000000000001');
      expect(generator.next, throwsStateError);
    });

    test('journal is versioned and excludes QR and tokens', () {
      final record = PendingOperationRecord(
        commandId: '20000000-0000-4000-8000-000000000001',
        operationType: PendingOperationType.stamp,
        membershipPublicId: 'mem_public_fixture',
        stampAmount: 2,
        purchaseAmountMinor: 10000,
        currency: 'IQD',
        transactionReferenceHash: _repeat('a', 64),
        createdAt: DateTime.utc(2026, 8, 2),
        lastCheckedAt: null,
        status: PendingOperationStatus.processing,
      );
      final encoded = jsonEncode(record.toJson());
      final restored = PendingOperationRecord.fromJson(jsonDecode(encoded));

      expect(restored?.commandId, record.commandId);
      expect(encoded, isNot(contains('qrPayload')));
      expect(encoded, isNot(contains('accessToken')));
      expect(encoded, isNot(contains('nonce')));
      expect(encoded, isNot(contains('signature')));
    });

    test('validates processing, completed, and failed recovery fixtures', () {
      expect(
        CommandRecoveryResult.fromJson(
          _fixture('operation-processing.fixture.json'),
        ).status,
        CommandRecoveryStatus.processing,
      );
      expect(
        CommandRecoveryResult.fromJson(
          _fixture('operation-completed.fixture.json'),
        ).status,
        CommandRecoveryStatus.completed,
      );
      expect(
        CommandRecoveryResult.fromJson(
          _fixture('operation-failed.fixture.json'),
        ).status,
        CommandRecoveryStatus.failed,
      );
    });
  });

  group('redaction, cache keys, and localized errors', () {
    test('redacts customer QR and M2 sensitive fields', () {
      const credential =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-';
      final output = const SensitiveRedactor().redact(
        '{"qrPayload":"$credential","merchantTransactionReference":"sale-1"}',
      );
      expect(output, isNot(contains(credential)));
      expect(output, isNot(contains('sale-1')));
      expect(output, contains('[REDACTED]'));
    });

    test('image cache key is the approved digest only', () {
      final cache = DigestImageCache(Dio());
      final digest = _repeat('a', 64);
      expect(cache.cacheKey(digest.toUpperCase()), digest);
      expect(() => cache.cacheKey('not-a-digest'), throwsException);
    });

    test('every stable M2 error has localized product copy', () {
      final strings = lookupAppLocalizations(const Locale('en'));
      final payload =
          jsonDecode(
                File(
                  'contracts/w4/m2/stable-error-codes.m2.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final errors = payload['codes']! as List<Object?>;
      for (final value in errors) {
        final code = value! as String;
        expect(
          strings.m2ErrorMessage(code),
          isNot(strings.genericError),
          reason: code,
        );
      }
    });
  });
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

String _repeat(String value, int count) => List.filled(count, value).join();
