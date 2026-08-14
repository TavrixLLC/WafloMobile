# Scanner parity

Pairing, normal customer scanning, server Review, and local Demo now reuse `ProfessionalScannerOverlay`, `WafloScannerRoundAction`, and `WafloScannerStatusPill`.

Shared behavior:

- real camera adapter where hardware is active;
- adaptive square target and the same corner geometry;
- restrained Coral beam on a 2300 ms cycle;
- beam only in ready/scanning;
- immediate stop on detection/resolution/background/error;
- same title/instruction/status hierarchy;
- actual torch state;
- Reduce Motion static target;
- safe-area, RTL, large-text, and semantic support.

Only authorized LOCAL_DEMO receives a discreet bottom-sheet simulation capability. The underlying camera presentation remains the same.
