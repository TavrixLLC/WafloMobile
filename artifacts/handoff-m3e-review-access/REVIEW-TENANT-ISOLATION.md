# Review tenant isolation

The provisioner creates one fixed `waflo-app-review` organization, one review Location, one non-login fictional Staff member, review-only programs/rewards/customers, and no real contact data. The organization is isolated from real tenant selection and is marked as a review fixture through fixed server-owned identities.

Server guards enforce exact organization/member/location/device bindings on each signed Review Tools boundary. Customer credentials are derived through the existing opaque QR security service and are bound to the review organization. Mobile cannot submit tenant, organization, Location, membership, or arbitrary record identifiers.

Review scenario/reset operations use the existing ledger/projection model and organization lock ordering. They delete/reseed only the fixed review membership records. Billing-blocked is simulated by the review organization's billing state; no Stripe customer/subscription is created. Wallet/provider mutations and customer communications are not created by the provisioner.

Database-backed HTTP assertions for cross-tenant QR denial, normal-device denial, rate limiting, no wallet/Stripe side effects, and reset isolation are authored but not executed in this environment because no isolated Backend test database configuration was available.
