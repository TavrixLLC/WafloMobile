# Staging E2E ownership

Execute `docs/m3a/staging-e2e-plan.md` after staging backend deployment. Use the
production UI and real physical phones; test/demo adapters remain disabled.

Failure owners are MOBILE, WEB/BACKEND, DEPLOYMENT, PROVIDER, CREDENTIAL, and
ENVIRONMENT. Wallet issuance/update delivery is Web/backend-owned. Mobile must
not fake a provider result or compensate for a deployed contract defect.
