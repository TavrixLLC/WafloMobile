# Device identity

Each installation generates an Ed25519 keypair on device. The public key is encoded as Base64 of RFC 8410 SubjectPublicKeyInfo DER (`302a300506032b6570032100` plus 32 raw bytes). Signatures are unpadded Base64URL.

One versioned secure record contains installation UUID, algorithm, public key, raw public bytes, private bytes, creation time, and key version. The public model exposes a private-key reference, never private material. Corrupt/missing records fail closed. Logout or deliberate repair deletes the identity; a normal update preserves it. Reinstall/clear-data creates a new identity and requires pairing.

The cryptography package zeroizes/destroys transient keypair handles where available. The private key is never transmitted, logged, placed in ordinary preferences, included in backup, or committed.
