# Identity — LDAP + Keycloak

## LDAP directory (sketch)

Use a **single logical DIT** for POSIX and application binds. Example layout (no secrets here):

```text
dc=tafaust,dc=org
├── ou=users           # posixAccount / inetOrgPerson (bm-uni style; was ou=people in older sketch)
├── ou=groups          # posixGroup (memberUid / uniqueMember)
├── ou=services        # technical accounts (read-only binds)
└── ou=kubernetes      # optional: Dex/LDAP connector subtree experiments
```

References (course-style layout; this repo uses **cn=config / OLC**, not static `slapd.conf`):

- [bm-uni.de — LDAP 02 Serverinstallation](https://bm-uni.de/ldap/ldap-02.html) (schemas, MDB, ACLs, indices, LDAPS notes)
- [YouTube — WVV_VGAMlCA](https://www.youtube.com/watch?v=WVV_VGAMlCA)
- [YouTube — 7Y0pHUZ7M6Q](https://www.youtube.com/watch?v=7Y0pHUZ7M6Q)

- **Users**: `uid=` entries under `ou=users` with `uidNumber`, `gidNumber`, `homeDirectory`.
- **Groups**: `cn=` under `ou=groups`; reference users with `memberUid` or `uniqueMember`.
- **TLS**: LDAPS or StartTLS to the directory; CA distributed via Ansible (`ldap_tls_cacert`).

## `ldap-01` VM sizing (homelab)

OpenLDAP + small user set = **tiny** footprint. Sane defaults on Proxmox:

| Resource | Minimum | Comfortable |
|----------|---------|-------------|
| vCPU | 1 | 2 |
| RAM | 512 MiB | **1–2 GiB** |
| Disk | 10 GiB root | **20 GiB** (logs, backups, growth) |
| NIC | internal bridge only (`vmbr2`) | same |

Scale up only if heavy sync (Keycloak federation churn) or big access logs on same disk.

## Automated install (Ansible)

Playbook [../ansible/playbooks/openldap-server.yml](../ansible/playbooks/openldap-server.yml) + role `openldap_server`: installs **slapd** on `ldap_servers`, seeds **`ou=users|groups|services|kubernetes`**, then **OLC** tuning (indices, limits, log, bm-uni-style ACLs at `{70}`–`{72}`). With **`ldap_server_domain: tafaust.org`** (see `ansible/inventories/prod/group_vars/ldap_servers.yml`): suffix **`dc=tafaust,dc=org`**, admin **`cn=admin,dc=tafaust,dc=org`**. Set **`ldap_admin_bind_password`** via Vault or `-e @secrets.yml` (never commit). **TLS** not configured by this role yet — add certs + `olcTLS*` separately or extend role.

## Keycloak

- Run Keycloak on k3s from `clusters/prod/manifests/keycloak/` via Argo (`clusters/prod/apps/platform/keycloak.yaml`).
- **User federation**: LDAP provider pointing at `ou=users` (or subtree). Use **read-only** federation for lab unless you explicitly want bi-directional sync.
- **OIDC clients**: Grafana, Argo CD, Infisical, etc. consume Keycloak realms/clients — prefer **short-lived tokens** and **no client secrets in Git** (use ExternalSecrets).

## Secrets

Never commit `bindDN` passwords, Keycloak admin, or `client_secret`. Use Ansible Vault on nodes, Infisical, or ExternalSecrets operators referencing an out-of-band secret store.
