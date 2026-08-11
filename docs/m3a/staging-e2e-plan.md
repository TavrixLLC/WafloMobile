# Staging physical E2E plan

Use Staff Mobile against `https://api.staging.waflo.app` and two physical
phones. Record every failure as MOBILE, WEB/BACKEND, DEPLOYMENT, PROVIDER,
CREDENTIAL, or ENVIRONMENT.

1. Web creates a merchant and location.
2. Web publishes an eight-stamp program with custom FILLED and EMPTY artwork.
3. Pair the Staff phone to the location.
4. Join as a customer on the second phone and obtain its membership QR.
5. Scan and verify 0/8, all EMPTY.
6. Add stamps and verify customer Web state updates.
7. Verify Wallet updates only through the Web/backend-owned architecture.
8. Scan again and verify 5/8 uses five FILLED and three EMPTY positions.
9. Complete the goal and verify 8/8 plus Reward Ready outside the grid.
10. Redeem with confirmation.
11. Verify completedCycles increments, progress is 0, rewardReady is false,
    and all eight grid positions are EMPTY.
12. Tap Scan next customer and verify no previous customer data remains.

Do not work around a deployed contract defect in Flutter. Capture sanitized
request IDs only in diagnostic evidence; never capture QR, tokens, customer PII,
or provider credentials.
