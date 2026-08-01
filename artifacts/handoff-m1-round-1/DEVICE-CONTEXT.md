# Device context

The app parses the authoritative W4 safe DTO and displays organization name,
staff name and role, device name/status/platform/version, current Location,
every assigned Location, earning/redemption capabilities, synchronization time,
and update policy.

Assigned Location count derives from the returned list. Empty and multiple lists
are supported. Public IDs are retained only for request integrity/domain mapping;
no internal or public identifiers are rendered in the UI. A mismatched device
public ID or unknown required enum fails closed as an invalid response.
