# Startup regression

## Root cause

`AppLifecycleBoundary` previously rendered outside `MaterialApp.router.builder`. Its `WafloReadyBeacon` could therefore access `WafloThemeContext.waflo` before the `WafloPalette` ThemeExtension existed, causing a null-check exception on a physical Android startup path.

## Repair

- `AppLifecycleBoundary` now renders inside `MaterialApp.router.builder`, beneath the configured application theme.
- `WafloThemeContext.waflo` has one centralized brightness-aware safe palette fallback for emergency/fail-safe render paths.
- The configuration failure screen retains strict environment validation but uses deliberate Waflo presentation and no configuration internals.
- Official marks are loaded from bundled assets. Missing-asset fallback uses the separate flow-status motif, not a hand-drawn logo.

## Regression coverage

Widget coverage explicitly renders the lifecycle/privacy layer and ready beacon without a `WafloPalette` ThemeExtension and asserts:

- no widget exception;
- privacy content renders;
- ready beacon renders.

The configuration-error screenshot also executes the intentional invalid-configuration presentation path without a widget exception.

Result: automated regression pass. Physical Android startup remains pending because no device was connected.
