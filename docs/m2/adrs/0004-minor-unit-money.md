# ADR 0004: Minor-unit money parsing

Status: Accepted

Purchase values are parsed from localized text directly to integer minor units using currency fraction metadata. Floating point, conversion, ambiguous grouping, excessive precision, and negative amounts are rejected to keep the signed payload exact.
