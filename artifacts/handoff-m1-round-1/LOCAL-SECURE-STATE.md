# Local secure state

The version-1 lifecycle marker records `neverPaired`, `pairing`, `paired`,
`recoveryRequired`, or `loggedOut` with an optional safe reason/request ID.

Boot evaluates lifecycle, identity, session, and pairing transaction together.
Contradictions fail closed: a paired identity without a session, a session
without identity, corrupt state, and completion ambiguity never route to an
ordinary fresh-install screen.

After server refresh rotation, local replacement is verified atomically. If
replacement fails, the unusable session is cleared, the device identity is
retained for manager-assisted recovery, and `recoveryRequired` is persisted.
Logout deliberately clears session, identity, pairing transaction, and safe
cache before marking `loggedOut`.
