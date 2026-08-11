# Deferred work

- Human sign-in: no approved shared identity contract; no Clerk or speculative
  Apple/Google sign-in is added.
- Notifications: preserved WIP concepts are not ported. Real sending remains a
  server capability and provider credentials never belong in Flutter.
- Wallet issuance/update delivery: Web/backend-owned. Mobile never issues a
  pass or claims provider delivery.
- Merchant stamp assets: the immutable M2 Mobile contract provides FILLED/EMPTY
  states and content digests but no asset bytes, URL, or colors. M3A keeps the
  exact two-state semantics and safe shapes; displaying merchant artwork needs
  an approved future contract rather than a fabricated fetch path.
- Manager approval acquisition, reversal, NFC, Smart Tap, POS, offline loyalty
  mutations, merchant administration, and analytics dashboards remain out of
  scope.
