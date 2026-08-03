# Membership resolution

Resolution sends the opaque QR and `en`/`ar` locale through the signed W4 endpoint. The response is rejected unless its request ID, Membership/status enums, progress/goal, reward-ready projection, nested projection, operation policy, reward status, Location eligibility, and artwork metadata are internally consistent.

Only contract-safe fields are shown: customer display name, Program, status, progress, goal, completed cycles, capability, rewards, purchase policy, daily allowance, current Location, and resolve time. Email, phone, raw internal identifiers, tokens, QR values, and credential suffixes are never shown.

A resolved Membership may remain visible when connectivity is lost, but mutation controls are disabled. The backend revalidates every mutation.
