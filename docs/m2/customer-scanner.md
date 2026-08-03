# Customer scanner

The customer scanner is separate from M1 pairing and reports `CUSTOMER_MEMBERSHIP_QR`; the pairing adapter reports `PAIRING_QR`. Camera startup follows an explicit Staff action. The adapter accepts only QR frames, caps candidates at 220 characters, pauses after the first candidate, debounces repeats, and exposes no gallery import or clipboard path.

The value is treated as an opaque bearer credential. It is never decoded for customer identity, displayed, logged, persisted, used as a route argument, or included in screenshots. Backgrounding and navigation stop the camera and clear transient credential memory. A retry requires a new explicit scan.
