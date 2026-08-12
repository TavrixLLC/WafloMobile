# Typography

## Latin

Manrope is bundled at weights 400, 500, 600, 700, and 800 and is the application theme family. The family is licensed under SIL Open Font License 1.1; the complete official Google Fonts license text is bundled as `Manrope-OFL.txt`.

## Arabic

Noto Sans Arabic is bundled for Arabic glyph shaping, locale-specific metrics, and the prescribed 400–800 weights. The application uses the official Google Fonts variable distribution (`NotoSansArabic[wdth,wght].ttf`), renamed to a platform-safe asset filename without modifying its bytes. The complete SIL Open Font License 1.1 text is bundled as `NotoSansArabic-OFL.txt`.

Licensing and upstream references are recorded in `assets/brand/fonts/LICENSE-NOTES.txt`. No font is fetched at runtime.

Semantic theme styles cover display, screen title, section title, customer identity, body, supporting text, label/button, status, and tabular loyalty progress. Widget and screenshot harnesses load the same bundled families as production.

Theme resolution is locale-aware: English uses Manrope with Noto Sans Arabic fallback; Arabic uses Noto Sans Arabic as its primary family with Manrope fallback for mixed Latin content. The selected locale updates both light and dark themes. This prevents bold Arabic controls from depending on platform fallback behavior.

Arabic screenshots were reviewed for glyph quality, line height, button/chip height, mixed Latin content, number alignment, and RTL spacing. The existing locale numeral policy remains unchanged.
