# ADR 004: Pending mutation blocks scanning

Status: accepted.

An ambiguous command is recovered by its original command ID. New scanning and
new mutations remain blocked until authoritative PROCESSING, COMPLETED, or
FAILED status is safely handled.
