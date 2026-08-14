# Architecture

## One user-facing entry

Pairing keeps normal merchant pairing dominant and exposes one secondary action: **Demo Access**.

| Build | Demo Access behavior |
|---|---|
| Development debug | Injects the local deterministic Demo runtime and debug UI bindings. No Backend is required. |
| Staging debug | Same local deterministic runtime, while preserving the canonical staging origin for all non-demo behavior. |
| Development/staging release | Local runtime, routes, controls, and fixture PIN are absent from AOT output. Demo Access uses the server-backed M3E flow. |
| Production/review | Existing server-backed Review credential, isolated Review tenant, signed Review session, and M3E security model. |

## Composition boundary

The shared app defaults to a deny-all `LocalDemoRuntime` and empty route/control providers. Only the development and staging entrypoints can inject `LocalDemoDebugBootstrap`, and only when Flutter's compile-time `kDebugMode` is true.

Widgets consume existing repository/domain seams. They do not contain networking, fixture branching, or scattered demo-mode data logic.

`LOCAL_DEMO` is presentation/QA state. It is not `NORMAL` or server-authorized `REVIEW`; it cannot coexist with an active real Staff/Review session.

## Session and exit

Entering local Demo creates no token or Staff session. Exiting clears in-memory fixtures, stops/disposes scanner state, resets local operation state, performs no logout API call, and returns to Pairing. Normal and server-backed Review session stores are not modified.
