# Purchase and money

Purchase amount is requested only when the authoritative policy enables it. `MinorUnitMoney` parses localized Latin, Arabic-Indic, and Persian digits to integer minor units. It rejects negatives, excessive precision, grouping ambiguity, missing values, and unsupported currency metadata; floating-point arithmetic and currency conversion are not used.

The required ISO currency code is always displayed. The optional merchant reference is bounded to 120 contract-valid characters, rejects card-like digit sequences, is redacted from logs, and is cleared after a conclusive result. Only minor units/currency and an optional SHA-256 reference hash may enter an ambiguous-operation record.
