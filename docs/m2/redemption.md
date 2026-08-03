# Redemption

Redemption requires a review screen and explicit confirmation. The review identifies the safe customer/Program/reward context, current progress, Location, expiration, instructions, and whether a final reward resets the cycle. Stale resolution is refreshed before review; mutation validation remains server-authoritative.

The request uses a new command UUID, signed request headers, the entitlement public ID from resolution, and the transient QR. Milestone success preserves progress. Final success immediately renders the authoritative `0 / goal`, increments completed cycles, marks reward-ready false, and shows every main-grid slot empty.
