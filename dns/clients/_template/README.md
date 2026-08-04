# Client template (DNS)

1. Copy to `clients/<your-client>/` and add `terraform.tfvars.example` (non-secret only).
2. Choose **one** Terraform root: `dns/terraform/environments/hetzner|ionos|hostinger/`.
3. Export the matching `TF_VAR_*` token; add `backend.tf` from that root’s `backend.tf.example`.

See [dns/README.md](../../README.md) and [example-hetzner/](../example-hetzner/terraform.tfvars.example).
