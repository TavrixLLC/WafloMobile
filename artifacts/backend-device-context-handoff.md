# Backend handoff — Staff device context

- Request: signed `GET /v1/staff/device-context` (`SignedDeviceApi.getContext`; no body).
- Mobile expects `data.organization.displayName` and `data.currentLocation.displayName` from the full `MobileStaffDeviceContext` response.
- Current response is the ID-only M2 shape: `data.organizationId` and `data.locationId`; Mobile therefore receives empty display names and shows “Unavailable.”
- Backend: return/populate the full nested `data.organization` and `data.currentLocation` objects (including non-empty `displayName`; preserve their existing `publicId`/capability fields), rather than the ID-only shape.
