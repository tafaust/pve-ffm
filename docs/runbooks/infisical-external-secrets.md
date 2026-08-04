# Infisical + External Secrets

## Infisical self-host

- Upstream: <https://infisical.com/docs/self-hosting/overview> (PostgreSQL + Redis required).
- **Bare metal / VM (homelab):** Ansible [playbooks/infisical-server.yml](../../ansible/playbooks/infisical-server.yml) on `infisical-01` (`192.168.20.8`) — Docker Compose; see [infisical-secrets.example.yml](../../ansible/inventories/prod/group_vars/infisical_servers/infisical-secrets.example.yml).
- **Kubernetes:** official **Helm** chart when ready; Argo scaffold in `clusters/prod/apps/platform/infisical.yaml`.
- **OIDC**: configure Infisical to trust **Keycloak** for human login to the Infisical UI.

## External Secrets Operator

Installed by Argo from `clusters/prod/apps/platform/external-secrets.yaml` (Helm chart pin in that file).

## Wiring

1. Create `ClusterSecretStore` or `SecretStore` pointing at Infisical API (URL, machine identity).
2. Per-namespace `ExternalSecret` resources pull keys into Kubernetes `Secret` objects consumed by Helm releases.

Never commit root tokens; bootstrap once and store in Ansible Vault offline.
