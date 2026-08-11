# Staff flow

Home has one dominant action: Scan customer. Organization, location, and the
Ready Beacon provide only the context needed for the next transaction. Pending
command recovery appears above Scan and blocks scanning.

The scanner accepts one candidate, debounces duplicate frames, pauses while
resolving, releases the camera on background, and never displays, copies,
persists, routes, or logs the QR. Flash and cancel controls have localized
tooltips and minimum touch targets.

The customer screen shows the customer name, program, two-state stamp grid,
progress, reward readiness outside the grid, and eligible actions. Inputs are
shown only when the authoritative policy requires them. Money stays integer
minor units and currency stays the three-letter policy value.

After a conclusive success, Scan next customer clears the QR, customer state,
purchase fields and reference, selected reward, operation result, and pending
journal acknowledgment before returning to the scanner. It never auto-opens
the camera.

Ambiguous mutations retain the same command ID and expose only Check again.
`PROCESSING` stays blocked, `COMPLETED` consumes the authoritative result, and
`FAILED` presents a safe localized action. This is not an offline queue.
