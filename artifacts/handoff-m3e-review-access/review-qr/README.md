# Review QR generation status

No QR PNG is committed yet. A static fixture made without the deployed environment's real QR signing secret would violate the approved customer QR contract.

After the Backend repair is deployed and the review tenant is provisioned, an authorized release operator runs the Backend provisioner with `--qr-output-dir=<secure-output-directory>`. It emits exactly:

- `customer-new.png`
- `customer-active-5-of-8.png`
- `customer-reward-ready-8-of-8.png`
- `customer-invalid.png`

The files encode only review-tenant opaque customer credentials using the existing QR protocol. Supply them through secure store-review operations and record their environment/expiry. Never substitute a production customer QR.
