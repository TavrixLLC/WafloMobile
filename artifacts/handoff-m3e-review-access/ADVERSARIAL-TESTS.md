# Adversarial tests

## Executed

- Distinct code format; ambiguous characters and normal six-digit pairing code rejected.
- No code retained in secure stores or signed Review Tools bodies.
- Explicit REVIEW session persistence; legacy records remain NORMAL.
- Normal sessions cannot call Review Tools.
- Session-mode mismatch fails device-context validation.
- Review scenario IDs are fixed; command IDs are generated; unknown scenario response fails closed.
- Same review device re-entry requires exact active organization/member/install/key binding.
- Review window closes authorization and signed sessions.
- Scenario/reset share loyalty organization locks.
- Exit Demo clears review session while preserving the device identity.
- Scanner single-flight, background lock, retry, torch state, and Reduce Motion behavior.

## Authored but environment-blocked

The Backend HTTP suite covers wrong code, normal-device denial, cross-org/cross-tenant QR denial, fixed select/reset, rate limiting, no plaintext audit material, and absence of wallet/Stripe records. It was not executed because this workspace has no isolated Backend test `DATABASE_URL`/test service configuration. Deployment/provider checks and concurrent reset-vs-mutation execution remain outstanding.
