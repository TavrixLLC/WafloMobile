# Brand token map

| Official token | Current Flutter token | Action |
|---|---|---|
| Waflo Brick `#AE3115` | `WafloColors.brick`, light primary/action | ADD / canonicalize |
| Flow Coral `#FF6B4A` | `WafloColors.coral`, controlled accent | ADD / canonicalize |
| Ember `#7D2311` | `WafloColors.ember`, pressed/deep brand | ADD |
| Warm Ink `#241916` | `WafloColors.ink`, primary text/native splash | ADD / remap |
| Soft Coral `#FFF0EC` | `WafloColors.softCoral`, primary container | ADD |
| Cloud `#F7F9FF` | `WafloColors.cloud`, light canvas | REMAP |
| White `#FFFFFF` | `WafloColors.white`, surface/on-brand | KEEP / centralize |
| Muted `#76645F` | `WafloColors.muted`, supporting text | REMAP |
| Success `#1F8F6A` | `WafloColors.success` | KEEP / centralize |
| Warning `#E6A23C` | `WafloColors.warning` | REMAP |
| Danger `#C93C2B` | `WafloColors.danger` | REMAP |
| Radius 8 | `WafloRadius.small` | ADD |
| Radius 14 | `WafloRadius.medium`, button/compact aliases | REMAP |
| Radius 22 | `WafloRadius.large`, card alias | REMAP |
| Radius 32 | `WafloRadius.extraLarge`, stage alias | REMAP |
| Radius 999 | `WafloRadius.pill` | KEEP |
| Shadow `0 12 32 rgba(36,25,22,.10)` | `cardShadow` + shared card decoration | REMAP / controlled use |
| Motion 160–240ms | `WafloMotion.immediate/standard/deliberate` | ADD |
| Manrope 400–800 | `fontFamily: Manrope` | REMAP |
| Noto Sans Arabic | locale font family/fallback | REMAP |

Removed current presentation authority: pine/green brand values, cream canvas, old semantic aliases, Roboto/Noto Naskh theme declarations, and arbitrary per-widget primary colors.

Official source tokens and conservative dark derivations are intentionally separated in `app_theme.dart`.
