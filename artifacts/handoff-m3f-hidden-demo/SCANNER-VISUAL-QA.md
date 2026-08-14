# Scanner visual QA

Front End Design review outcome:

| Surface | Classification | Notes |
|---|---|---|
| Camera hierarchy | KEEP | Camera remains the visual hero. |
| Adaptive target/corners | KEEP | Strong geometry without neon or glow. |
| 2.3-second beam | KEEP | Quiet motion, isolated from camera rebuilds. |
| Pairing scanner | POLISH completed | Replaced the former card-like separate scanner presentation. |
| Manual entry placement | POLISH completed | Secondary, generic action behind scanner. |
| Demo controls | KEEP | Authorized-only bottom sheet; no permanent overlay. |
| Arabic/dark/large text | KEEP with physical recheck | Existing executable matrices retained. |

The Android physical-device integration matrix completed successfully in
portrait, including the unified scanner lifecycle and both hidden manual-entry
routes. Final M3F pixels still require owner visual review on the physical
device, so no owner visual approval is claimed.
