# Localization

Flutter's generated ARB workflow provides typed English (`en`) and Arabic (`ar`) strings. Device locale is the default, an explicit user choice is persisted, and unsupported locales fall back to English. Pluralized location counts and parameterized time/version/request references are generated.

All production UI strings are localized. Arabic receives automatic RTL direction; layouts use directional padding/alignment. Backend `error.code` is mapped to safe localized copy, while a request ID may be shown as a support reference. Raw server messages and payloads are never presented as authoritative UI.
