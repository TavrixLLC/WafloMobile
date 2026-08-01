# ADR 004: Ed25519 key storage

Status: accepted.

Generate Ed25519 on-device, export only SPKI public material, and store the versioned private record exclusively through platform secure storage with backup/sync disabled. Reinstall/repair requires a new pairing.
