import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations_en.dart';
import 'package:waflo_staff/core/localization/localization_extensions.dart';

void main() {
  test(
    'isolates the retired M2 threshold code as a safe compatibility alias',
    () {
      final strings = AppLocalizationsEn();
      expect(
        strings.m2ErrorMessage('PURCHASE_THRESHOLD_NOT_MET'),
        contains('required minimum'),
      );
      expect(
        strings.m2ErrorMessage('PURCHASE_AMOUNT_BELOW_MINIMUM'),
        strings.m2PurchaseThreshold,
      );
    },
  );

  test('billing denial is safe and does not imply a local mutation', () {
    final message = AppLocalizationsEn().m2ErrorMessage(
      'OPERATION_BILLING_BLOCKED',
    );
    expect(message, contains('No customer progress changed'));
    expect(message, contains('Merchant Web'));
  });

  test('classifies every current Staff authority loss distinctly', () {
    expect(
      classifyFailure(const ApiFailure('STAFF_USER_DEACTIVATED')),
      FailureDisposition.staffUserDeactivated,
    );
    expect(
      classifyFailure(const ApiFailure('STAFF_MEMBERSHIP_INACTIVE')),
      FailureDisposition.staffMembershipInactive,
    );
    expect(
      classifyFailure(const ApiFailure('STAFF_LOCATION_ASSIGNMENT_INVALID')),
      FailureDisposition.staffLocationAssignmentInvalid,
    );
  });
}
