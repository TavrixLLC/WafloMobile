# Purchase currency

`purchaseCurrency` is represented as `String?` in the generated/domain request model. Request construction accepts exactly three ASCII letters, uppercases them, and rejects shorter/longer values, digits, symbols, objects, and arrays. Money remains integer minor units; UI currency comes from authoritative policy and no conversion exists.

Coverage includes `IQD`, lowercase `usd`, `US`, `USDD`, `12A`, `US$`, and schema rejection of object/array values. Arabic-digit amount input remains supported at the presentation boundary.
