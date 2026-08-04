# DNS Terraform roots (pick one provider)

| Directory | Provider | Notes |
|-----------|----------|--------|
| [hetzner/](hetzner/) | Hetzner DNS (`timohirt/hetznerdns`) | Zone + optional Mailcow RR module |
| [ionos/](ionos/) | IONOS Cloud DNS (`ionos-cloud/ionoscloud`) | Zone + optional Mailcow RR module |
| [hostinger/](hostinger/) | Hostinger (`hostinger/hostinger`) | **Records only** — create zone in hPanel first; optional Mailcow module |
| [technitium/](technitium/) | Technitium (`darkhonor/technitium`) | Self-hosted internal DNS — VM install manual; API token + `server_url` |

No Cloudflare / Route53 roots in this repo by design.

Copy `backend.tf.example` → `backend.tf`, set credentials via `TF_VAR_*` or env vars documented in each README.
