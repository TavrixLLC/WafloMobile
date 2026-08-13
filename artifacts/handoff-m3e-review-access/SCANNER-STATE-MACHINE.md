# Scanner state machine

Implemented states cover initializing camera, requesting permission, denied, permanently denied, ready/scanning, candidate captured, resolving, resolved, invalid, expired, network failure, resolve failure, unavailable camera, and background.

- Exactly one candidate is delivered while single-flight is locked.
- Capture pauses the camera and beam immediately.
- Invalid/expired results use a 1.4-second controlled recovery before rearming.
- Network/resolve errors require explicit retry.
- Background stops camera and animation; foreground never replays a delivered candidate.
- Leaving scanner stops torch/camera and disposes the controller.
- Rapid Scan returns only after explicit Staff action with cleared QR/customer/input state.
