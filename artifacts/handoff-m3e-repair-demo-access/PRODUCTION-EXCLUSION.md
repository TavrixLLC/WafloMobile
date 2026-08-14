# Production exclusion

Production exclusion is structural and verified at two levels.

## Source composition

- shared providers instantiate only the deny-all release runtime;
- shared router defaults to no local Demo routes;
- shared scanner/approval control slots default to empty widgets;
- the production entrypoint does not import the debug bootstrap;
- development/staging entrypoints inject debug bindings only behind compile-time `kDebugMode`;
- production configuration sets `WAFLO_LOCAL_DEMO_ENABLED=false` and rejects a true value;
- local scenario paths exist only in the debug composition root.

## Release binary proof

`tool/verify_local_demo_apk.dart` extracts each release APK and inspects every `libapp.so`. It fails if it finds:

- local scenario route markers;
- scanner simulation control keys;
- the local App Lock fixture PIN.

Both staging release and production release passed. CI rebuilds both release APKs and repeats this binary inspection.

Production **Demo Access** therefore remains the existing server-backed M3E Review Access route. The local fixture provider cannot be instantiated or reached by route/deep link in a release binary.
