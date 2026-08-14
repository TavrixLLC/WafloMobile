# Manual-code router

Typed intents:

- `normalPairing`: existing `waflo-pair-v1` opaque payload, passed unchanged to the existing parser/flow.
- `serverReview`: short credential-shaped input, normalized for usability and submitted to existing server authority. Mobile does not decide validity.
- `localDemo`: exact debug-only injected value, compared by the debug resolver without logging or persistence.

The UI remains category-neutral and LTR-safe inside Arabic RTL. Normal customer manual lookup is not an approved Mobile contract and was not invented.

The owner code is supplied only with `--dart-define=WAFLO_LOCAL_DEMO_CODE=<OWNER_LOCAL_DEMO_CODE>`. If absent, local Demo entry is unavailable.
