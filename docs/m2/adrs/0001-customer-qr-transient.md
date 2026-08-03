# ADR 0001: Customer QR remains transient

Status: Accepted

The customer QR is a bearer credential. It is held only in a private coordinator field during resolve/mutation and cleared on background, navigation, completion, failure, or session blocking. It is excluded from public state, routes, logs, screenshots, analytics, and persistence. Recovery uses public IDs and command ID, never the QR.
