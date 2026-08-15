# Scanner parity

Normal, authorized local Demo, and server-backed Review continue to use one
canonical scanner presentation. No second visual scanner was introduced.

## Preserved production behavior

- Real camera and permission adapter.
- Start/background/resume lifecycle.
- Torch state and recovery.
- Candidate debouncing, duplicate protection, and single-flight resolution.
- Authoritative QR parsing and server resolution.
- No fake offline mutation or pre-authoritative success.
- Haptics, accessible target semantics, retry, and error recovery.
- Typed manual-code entry remains the hidden M3F Demo/Review route.

## A+ presentation

- Full-bleed dark camera stage with subtle diagonal texture.
- Responsive 28-unit target, coral corner brackets, and status rail.
- 2.3-second beam only while camera is actively ready/scanning.
- Beam stops/changes after capture, detection, resolution, or failure.
- Reduced Motion keeps a clear static scan target rather than removing the UI.
- RTL, dark, and 200% evidence is included in the M3G screenshots.

M3F scanner lifecycle and parity widget tests pass unchanged in intent.
