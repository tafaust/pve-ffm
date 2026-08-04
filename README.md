# pve-ffm — homelab GitOps and Ansible

Infrastructure-as-code for a Proxmox-based lab: **VM/LXC creation stays manual** (Web UI); **Ansible** configures guests; **Argo CD** (default) syncs Kubernetes platform and userspace workloads from this repository.

## Layout

| Path | Purpose |
|------|---------|
| [ansible/](ansible/) | Inventories, playbooks, roles (hardening, SSSD→LDAP, k3s node stubs) |
| [clusters/prod/](clusters/prod/) | Argo CD app-of-apps (`argocd/`), child apps in `apps/platform/`, `manifests/` Kustomize (includes **SigNoz** values under `manifests/signoz/`) |
| [dns/](dns/) | DNS Terraform (**Hetzner / IONOS / Hostinger / Technitium**) + Mailcow RR modules |
| [clients/](clients/) | Optional repository-wide client/tenant template (`clients/_template/`) |
| [identity/](identity/) | LDAP DIT sketch, Keycloak federation notes (no secrets) |
| [docs/](docs/) | Architecture, runbooks, ADRs (`docs/adr/`), Renovate notes |
| [renovate.json](renovate.json) | Minimal Renovate config (see [docs/renovate.md](docs/renovate.md)) |

Forks: see [docs/contributing-for-forks.md](docs/contributing-for-forks.md).

## Defaults (override in inventory or `group_vars`)

- Internal lab bridge (Proxmox UI): **`vmbr2`**
- Internal CIDR: **`192.168.20.0/24`**

See [ansible/inventories/prod/group_vars/all/homelab.yml](ansible/inventories/prod/group_vars/all/homelab.yml).

## Remote access

Ansible targets are usually reached over **site-to-site WireGuard** (e.g. FRITZ!Box ↔ datacenter) into `192.168.20.0/24`. Optional **NetBird** overlay is documented in [docs/runbooks/remote-access.md](docs/runbooks/remote-access.md).

## Prerequisites

- **Proxmox VE**: create VMs/LXCs and attach NICs to the internal bridge in the **Web UI** (or your own API automation outside this repo).
- **k3s** (or another Kubernetes distro) for workloads managed by Argo CD.
- **kubectl** and **Argo CD** on the cluster; Git SSH/HTTPS credentials for Argo to pull this repo.
- **SSH** from your workstation to `192.168.20.x` lab hosts (typically via VPN).

## Security

- Do **not** commit real passwords, API tokens, or `kubeconfig` with credentials.
- Use Ansible Vault or Infisical (see docs) for secrets.

## Docs

- [docs/runbooks/mailcow-reverse-proxy.md](docs/runbooks/mailcow-reverse-proxy.md) — Mailcow vs **ingress-nginx** / Traefik
- [docs/adr/](docs/adr/) (e.g. [0001 SigNoz backend](docs/adr/0001-signoz-as-observability-backend.md))
- [docs/runbooks/](docs/runbooks/)
- [docs/runbooks/signoz.md](docs/runbooks/signoz.md) — observability: UI over VPN, OTLP endpoints, retention, backups; **single-node vs HA**
- [docs/cloud-init-snippet.example.yml](docs/cloud-init-snippet.example.yml)
- [docs/security-advisories.md](docs/security-advisories.md)
- [docs/renovate.md](docs/renovate.md)
