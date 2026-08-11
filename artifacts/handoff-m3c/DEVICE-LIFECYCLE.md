# Device authority lifecycle

Current signed-boundary authority errors are distinct:

| Safe code | Mobile behavior |
|---|---|
| `STAFF_USER_DEACTIVATED` | Stop operations; explain that the Staff account is inactive. |
| `STAFF_MEMBERSHIP_INACTIVE` | Stop operations; explain that organization access is inactive. |
| `STAFF_DEVICE_REVOKED` | Stop operations; show the established revoked-device state. |
| `STAFF_LOCATION_ASSIGNMENT_INVALID` | Stop operations; explain that the paired Location assignment is no longer valid. |

Authority loss clears the active session and prevents route navigation from restoring operational access. No mutation is queued, and later token expiry is not used as the enforcement boundary.

Mobile has no Location selector, Location self-assignment, or Merchant location-assignment route usage. The active Location remains derived from the paired device session.
