# DNS as code (Terraform)

Supported DNS providers in this repo (**only**):

| Provider | Terraform provider | Environment root |
|----------|--------------------|------------------|
| **Hetzner DNS** | `timohirt/hetznerdns` | [terraform/environments/hetzner/](terraform/environments/hetzner/) |
| **IONOS Cloud DNS** | `ionos-cloud/ionoscloud` | [terraform/environments/ionos/](terraform/environments/ionos/) |
| **Hostinger** | `hostinger/hostinger` | [terraform/environments/hostinger/](terraform/environments/hostinger/) |
| **Technitium** (self-hosted internal) | `darkhonor/technitium` | [terraform/environments/technitium/](terraform/environments/technitium/) |

Cloudflare / AWS Route53 roots were **removed** by design.

## Layout

| Path | Purpose |
|------|---------|
| [terraform/modules/](terraform/modules/) | `hetzner-dns-zone`, `ionos-dns-zone`, `mailcow-dns-{hetzner,ionos,hostinger}`, `technitium-internal-dns` |
| [terraform/environments/](terraform/environments/) | **One directory per provider** (clean `required_providers` — no dummy credentials for unused clouds) |
| [clients/](clients/) | Example `terraform.tfvars` fragments (no secrets) |

## Mailcow

Per-provider Terraform modules create **mail-related DNS RRs** (A, MX, SPF, optional DKIM/DMARC, autoconfig/autodiscover). They do **not** install Mailcow.

**Kubernetes reverse proxy** options (ingress-nginx vs Traefik vs DNS-only): [docs/runbooks/mailcow-reverse-proxy.md](../docs/runbooks/mailcow-reverse-proxy.md).

## Credentials (never commit)

```bash
# Hetzner
export TF_VAR_hetzner_dns_api_token="***"

# IONOS (provider also reads IONOS_TOKEN)
export TF_VAR_ionos_token="***"

# Hostinger
export TF_VAR_hostinger_api_token="***"

# Technitium (internal)
export TF_VAR_technitium_server_url="https://dns.lan:5380"
export TF_VAR_technitium_api_token="***"
# or: TECHNITIUM_SERVER_URL / TECHNITIUM_API_TOKEN
```

## Toolchain

Terraform version pinned for asdf in [`.tool-versions`](.tool-versions).

## Client profile pattern

1. Copy `clients/_template/README.md` workflow.
2. Pick `terraform/environments/<hetzner|ionos|hostinger|technitium>/`, add `backend.tf` from `backend.tf.example`.
3. Keep secrets in env / CI OIDC / vault — not in Git.
