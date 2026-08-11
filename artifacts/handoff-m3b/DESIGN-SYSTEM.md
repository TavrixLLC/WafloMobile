# Design system

- Counter Ink `#171A18`: primary content and scanner foundation
- Waflo Evergreen `#006B55`: decisive action and readiness
- Signal Mint `#8EDCC5`: dark-mode action and positive signal
- Receipt `#F7F6F1`: quiet operational canvas
- Warning Amber `#B45F00`: recoverable/pending attention
- Safety Red `#BA2D27`: revoked/compromised only

Semantic light/dark tokens cover canvas, surfaces, text, disabled states,
actions, success, warning, error, borders, focus, and scanner overlay. A shared
spacing, radius, touch-target, and immediate-motion vocabulary replaces random
per-screen values. QR-corner geometry is reserved for scanning and next-customer
moments.

The main stamp grid remains exactly FILLED or EMPTY. Its adaptive layouts use
4/3/4/5/6-column strategies for common goals while preserving 40–58 logical
pixel slots and centered orphan rows.
