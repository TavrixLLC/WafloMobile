# Brand conformance audit

Authority reviewed before implementation:

- `Developer/README.md`
- `Developer/waflo-brand-manifest.json`
- `Developer/waflo-design-tokens.json`
- `Developer/waflo-tokens.css`
- `Guidelines/Waflo-Brand-Guidelines.pdf`
- supplied brand boards, color system, application concepts, app icons, logos, and Arabic readme

## Classification

| Area | Baseline | M3D result | Notes |
|---|---|---|---|
| App icon | OFF_BRAND | BRAND_MATCH | Official Apple/app icon authority drives legacy and iOS derivatives. |
| Android adaptive icon | MISSING | BRAND_MATCH | Official foreground and Brick background configured. |
| Android monochrome icon | MISSING | BRAND_MATCH | Official monochrome asset configured for Android 13+. |
| iOS icon | OFF_BRAND | BRAND_MATCH | Opaque RGB derivatives generated from official 1024 source. |
| Native splash | OFF_BRAND | BRAND_MATCH | Warm Ink plus official mark; Android 12+ handled separately. |
| Flutter startup | PARTIAL | BRAND_MATCH | Official trust-transition identity; no artificial delay. |
| Configuration fail-safe | OFF_BRAND | BRAND_MATCH | Official brand shell, safe copy, no internal configuration detail. |
| Logos/marks | MISSING | BRAND_MATCH | Supplied raster exports used at trust transitions only. |
| Light colors | OFF_BRAND | BRAND_MATCH | Exact Cloud, White, Ink, Brick, Coral, and Soft Coral mapping. |
| Dark colors | PARTIAL | BRAND_MATCH | Conservative derived palette documented separately. |
| Typography | OFF_BRAND | BRAND_MATCH | Manrope and Noto Sans Arabic bundled; no runtime font fetch. |
| Cards/surfaces | PARTIAL | BRAND_MATCH | Official 22 radius and controlled Warm Ink shadow. |
| Buttons/inputs | PARTIAL | BRAND_MATCH | Brick primary, Ember press, distinct destructive semantics. |
| Status components | PARTIAL | BRAND_MATCH | Brand shell plus success/warning/danger semantics. |
| Pairing | PARTIAL | BRAND_MATCH | Official mark added without exposing cryptography. |
| Home | PARTIAL | BRAND_MATCH | One dominant Brick scan action; operational context remains compact. |
| Scanner | PARTIAL | BRAND_MATCH | Camera-first; brand is limited to frame/status/controls. |
| Customer/loyalty | PARTIAL | BRAND_MATCH | Brand chrome frames merchant-owned visuals. Grid remains FILLED/EMPTY only. |
| Stamp/redeem | PARTIAL | BRAND_MATCH | Transaction hierarchy reconciled without semantic change. |
| Manager approval | PARTIAL | BRAND_MATCH | Production-v1 states use the same branded recovery language. |
| Success | PARTIAL | BRAND_MATCH | Useful authoritative result plus dominant Scan next customer action. |
| Error/blocked | PARTIAL | BRAND_MATCH | Severity-specific surfaces; no generic red-page treatment. |
| App Lock | PARTIAL | BRAND_MATCH | Warm official mark, calm PIN/biometric shell; security unchanged. |
| Device & Security | PARTIAL | BRAND_MATCH | Official type/surface hierarchy, no crypto exposure. |
| Settings | PARTIAL | BRAND_MATCH | Minimal operational settings preserved. |
| Arabic | PARTIAL | BRAND_MATCH | Noto Sans Arabic, true RTL, native fixture context, reviewed screenshots. |
| Accessibility | PARTIAL | BRAND_MATCH | Contrast, semantics, touch targets, and 200% layouts retained. |

## Repository audit classification

- Old generic app icon pixels were replaced in active native pipelines.
- Old native splash identity was replaced in active Android/iOS launch resources.
- Stale green/pine presentation colors were removed from production presentation source and locked by `tool/brand_lint.dart`.
- Legacy `assets/fonts/Roboto-Regular.ttf` and `assets/fonts/NotoNaskhArabic-Regular.ttf` remain as tracked historical source files but are no longer declared in `pubspec.yaml`, loaded by tests, or bundled in the app.
- Historical handoff screenshots and M2 contract evidence were not rewritten.
- Existing TODO/FIXME references outside M3D presentation work remain classified as pre-existing development/test documentation, not launch-time UI copy.

## Design conclusion

The final system is a warm retail instrument: Cloud and White provide calm working space; Brick identifies the next Staff action; Coral is a controlled accent; official marks appear only at trust transitions. Merchant loyalty artwork is not recolored or replaced by Waflo chrome.
