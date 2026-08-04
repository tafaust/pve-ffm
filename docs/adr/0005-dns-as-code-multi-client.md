# ADR 0005 — DNS as code (Hetzner, IONOS, Hostinger only)

## Status

Accepted (supersedes multi-cloud wording)

## Context

Operators want **Terraform-managed DNS** aligned to European/registrar DNS APIs, plus **Mailcow** RR sets, without dragging in Cloudflare/Route53. Multi-provider in **one** root forces unused `provider` blocks and confuses forks.

## Decision

- Support **exactly three** DNS backends: **Hetzner DNS**, **IONOS Cloud DNS**, **Hostinger** (`hostinger/hostinger`).
- **One Terraform environment root per provider** under `dns/terraform/environments/{hetzner,ionos,hostinger}/`.
- **Mailcow**: separate modules `mailcow-dns-hetzner`, `mailcow-dns-ionos`, `mailcow-dns-hostinger` sharing the same variable contract where possible.
- **Kubernetes edge**: document **ingress-nginx** (default in this repo) vs **Traefik** vs DNS-only for Mailcow HTTP/SMTP in `docs/runbooks/mailcow-reverse-proxy.md` — not decided in Terraform.

## Consequences

- Forks pick one `environments/<provider>/` tree; credentials stay single-vendor.
- Cloudflare/Route53 modules **removed**; migrate old state out-of-band if needed.

## Links

- [dns/README.md](../../dns/README.md)
- [docs/runbooks/mailcow-reverse-proxy.md](../../docs/runbooks/mailcow-reverse-proxy.md)
