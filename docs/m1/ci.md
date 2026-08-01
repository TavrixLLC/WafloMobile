# Continuous integration

`.github/workflows/ci.yml` runs generation-diff checks, formatting, fatal analysis, tests/coverage/goldens, repository security scanning, three Android flavor builds, and fake integration tests on an Android emulator. Artifacts expire after 14 days and concurrent superseded runs are cancelled.

`.github/workflows/ios.yml` runs on macOS, repeats analysis/tests, and compiles development, staging, and production without code signing. No certificate or provisioning profile is stored. A production release workflow is intentionally absent.

These workflows are configured but cannot be reported as passed until the repository is pushed and GitHub Actions returns exact run results.
