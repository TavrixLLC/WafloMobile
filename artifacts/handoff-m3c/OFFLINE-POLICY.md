# Online-only mutation policy

Production-v1 loyalty mutations remain online-only.

Mobile does not implement an offline stamp, redeem, reverse, approval retry, or background synchronization queue. Network failure before submission shows an immediate offline/retry state. Network ambiguity after submission preserves the original command only for authoritative command-status recovery.

No local state is allowed to authorize loyalty progress, reward readiness, billing eligibility, Location authority, or Manager approval.
