# Scanner Demo QA

Local Demo reuses the real M3E scanner screen, controller, camera adapter, 2.3-second Waflo beam, haptic abstraction, torch lifecycle, debounce, single-flight guard, and background/resume handling.

The debug-only **Demo controls** pill opens a bottom sheet; it does not cover the scan target. Fixed actions are:

- Simulate valid QR
- Simulate invalid QR
- Simulate expired QR
- Simulate network failure
- Reset scanner

The sequence distinguishes optical detection from authoritative resolution presentation:

1. active camera/scan beam;
2. code detected, beam stopped, single-flight locked, subtle haptic;
3. customer loading;
4. real Customer screen using a deterministic local fixture.

Invalid/expired/network simulations keep the real scanner state machine and recovery presentation. Reduce Motion leaves a static target. Arabic, dark mode, 200% text, semantics, and flashlight touch targets remain covered by the M3E widget/screenshot regressions.

The controls and their route keys are absent from release AOT output. Production never receives scanner simulation actions.

Physical APK installation passed. Camera/torch/touch interaction awaits owner unlock of the connected Android phone; no iOS physical claim is made.
