# Roles

| Role | Purpose |
|------|---------|
| `common_hardening` | **Ubuntu / Debian:** UFW, apt, unattended-upgrades. **openSUSE Tumbleweed:** firewalld, zypper, daily update timer. Both: sshd/fail2ban/auditd/sysctl, AppArmor check. See [ansible/README.md](../README.md) matrix. |
| `sssd_ldap` | **Ubuntu / Debian** when `sssd_ldap_enabled: true`: SSSD + `nsswitch` + `pam_mkhomedir`, TLS to LDAP, optional access filter / SSH public key attribute. |
| `openldap_server` | **Ubuntu / Debian** on `ldap_servers`: `slapd` + debconf, **`ou=users`** tree, **cn=config** tuning (indices, limits, log, bm-uni-style ACLs). |
| `k3s_node` | **Ubuntu / Debian:** `INSTALL_K3S_VERSION` pin, server or agent, `--flannel-backend=none --disable-network-policy`, disables Traefik + ServiceLB for Cilium-oriented clusters. |
| `infisical_server` | **Ubuntu / Debian** on `infisical_servers`: Docker Engine + Compose; Infisical + Postgres 14 + Redis. |

Use Ansible Vault for `ldap_admin_bind_password` (OpenLDAP install), `ldap_bind_password` (SSSD), Infisical keys (`infisical_encryption_key`, `infisical_auth_secret`, `infisical_postgres_password`), `k3s_registration_token` (unless using `K3S_JOIN_TOKEN` env for workers).
