# Ambiguous operation recovery

The versioned one-entry journal is not an offline queue. It contains only safe public IDs, command ID, safe operation fields, timestamps, and status. It never contains QR/token/signature/nonce/full purchase reference. PROCESSING, COMPLETED, FAILED, and NOT FOUND follow the W4 command contract.
