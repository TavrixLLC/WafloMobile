# Architecture

```text
Public Pairing
  → normal scanner
  → Enter code instead
  → ManualCodeIntentResolver
       normal pairing payload → existing pairing flow
       review-shaped code → existing server Review authorization
       injected owner code (debug root only) → LOCAL_DEMO
```

`ProductManualCodeIntentResolver` contains no local credential, fixture, or local-Demo branch. Development/staging debug entrypoints inject `DebugManualCodeIntentResolver`; production imports neither that resolver nor the debug composition root.

LOCAL_DEMO creates no Staff session or fake access credential. Its operations remain deterministic fixture state. NORMAL and REVIEW retain Ed25519/session/server authority. Widgets do not contain code-category string checks.
