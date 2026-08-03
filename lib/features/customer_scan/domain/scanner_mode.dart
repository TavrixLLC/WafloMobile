enum ScannerMode {
  pairingQr('PAIRING_QR'),
  customerMembershipQr('CUSTOMER_MEMBERSHIP_QR');

  const ScannerMode(this.contractValue);

  final String contractValue;
}
