# Physical E2E readiness

Mobile-side implementation is ready for physical staging validation, subject to external readiness.

Before execution, verify staging is deployed from Backend SHA `763f2dfccdb24fb9bfa16457f0e49936840e20a1` and deployment readiness is green. Then execute the supplied `production-v1-e2e-checklist.md` without reducing its scope.

Required physical coverage includes clean install, the fixed staging origin, Merchant-provisioned Staff Location assignment, pairing, relaunch persistence, customer resolve, stamp, reward ready, redeem with and without approval, authority and Location restrictions, response-loss command recovery, customer Wallet-observed state, final redemption reset, and concurrency where available.

Manual-only dependencies:

- real Android and iOS devices with camera access;
- Merchant Web Owner/Manager approval action;
- staging deployment confirmation for the exact authority SHA;
- platform signing/provisioning for distributable iOS hardware builds;
- real customer Web/Wallet observation where required by the canonical checklist.

Physical PASS is not claimed in this handoff.
