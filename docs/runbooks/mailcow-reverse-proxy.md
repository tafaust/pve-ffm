# Mailcow ↔ Kubernetes reverse proxy

## What this repo uses today

**ingress-nginx** (Helm) — see `clusters/prod/apps/platform/ingress-nginx.yaml`. HTTP/HTTPS `Ingress` + `IngressClass` **nginx**. **No** first-class SMTP/IMAP/TCP in stock chart (TCP Services exist as extra chart values / `ConfigMap` stream snippets; ops-heavy).

Mailcow default install = **Docker on a VM/LXC**, not a pod. DNS (this repo) points **A/MX** at Mailcow host IP. That is the normal split: **cluster = apps**, **VM = mail stack**.

## Goal: “link” webmail / ACME / autodiscover to cluster edge

Pick one pattern:

| Option | When | How |
|--------|------|-----|
| **A** — DNS only, no cluster proxy | Simplest, works everywhere | `mailcow-dns-*` modules → A/MX/TXT to Mailcow IP. HTTPS served by **Nginx on Mailcow host** (recommended upstream). |
| **B** — HTTP(S) via **ingress-nginx** to Mailcow LAN IP | Want single public IP = LB, TLS at ingress | `Service` type **ExternalName** is DNS-only (bad for IP). Use **Endpoints** + headless `Service` pointing to Mailcow private IP, then `Ingress` backend to that `Service`. Set `proxy-real-ip` / `X-Forwarded-*` so Mailcow sees client IP. **SMTP still** direct to Mailcow IP (not through ingress-nginx without stream config). |
| **C** — **Traefik** (replace or add) | Need **TCP/UDP** routes (SMTP submission, IMAPS) through same LB | Traefik **IngressRouteTCP** / entrypoints on 25/465/993 + TLS passthrough or termination. Bigger change: swap chart or run second ingress class. |
| **D** — **MetalLB** + **pure L4** | Bare UDP/TCP to Mailcow | LB IP fronts mail ports; no HTTP routing smarts. |

## Recommendation

- **Production-ish:** **A** (Mailcow nginx) + Terraform DNS modules for all mail RRs.
- **Single edge IP / TLS centralization:** **B** for **HTTPS only** (SOGo, rspamd UI, ACME HTTP-01 if you offload); keep **SMTP/IMAP** to Mailcow public/LAN IP or add **C** later.

## Traefik vs ingress-nginx (short)

- **ingress-nginx**: huge ecosystem, familiar `Ingress`, TCP behind extra config.
- **Traefik**: CRDs + TCP/UDP nicer for “one LB many protocols”; learning curve + CRD surface.

Switching default in GitOps = replace `ingress-nginx` Application + migrate existing `Ingress` to same class name / annotations.

## Related

- [dns/terraform/modules/mailcow-dns-hetzner](../../dns/terraform/modules/mailcow-dns-hetzner/README.md) (and ionos / hostinger siblings)
- [Mailcow DNS prerequisites](https://docs.mailcow.email/getstarted/prerequisite-dns/)
