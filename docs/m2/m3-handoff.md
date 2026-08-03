# M3 handoff

M2 intentionally stops at online Staff operations. The following remain for M3 decision and contract work: Manager approval acquisition, Manager PIN/QR, reversals, expanded operation history, and any additional security/risk workflow explicitly assigned to M3.

M3 must preserve the M2 invariants: customer QR remains transient, command recovery never becomes an offline queue, the main stamp renderer remains exactly two-state, money remains integer minor units, and Manager-required rewards cannot be redeemed without an authoritative approved flow.

Do not infer M3 request/response fields from the M2 unavailable state. Start from a separately approved backend contract.
