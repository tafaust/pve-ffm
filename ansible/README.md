# Ansible — homelab hosts

## Toolchain (asdf)

Repo pins Python under `ansible/` ([.tool-versions](.tool-versions)); install **ansible-core** into a venv (asdf has no first-party `ansible` plugin).

```bash
asdf plugin add python https://github.com/asdf-community/asdf-python.git
cd ansible
asdf install
uv venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
ansible-playbook --version
```

Use `source .venv/bin/activate` (or direnv) before `ansible-playbook`. `uv pip` reads same [requirements.txt](requirements.txt) as old pip.

## OS

**Ubuntu Server 24.04 LTS** (Debian family) is the primary target; **openSUSE Tumbleweed** (`ansible_os_family: Suse`) is supported for `common_hardening` (zypper + firewalld instead of apt + UFW). Other roles remain Debian-only until ported.

Proxmox VMs: NIC on internal bridge **`vmbr2`**, subnet from `homelab_internal_cidr`. LXCs work if you install the same packages.

## Inventory and vars layout

| Path | Purpose |
|------|---------|
| [inventories/prod/hosts.yml](inventories/prod/hosts.yml) | Hosts and groups (`lab_prod`, `lab_staging`, `ldap_servers`) |
| [inventories/prod/group_vars/all/homelab.yml](inventories/prod/group_vars/all/homelab.yml) | Lab CIDR + bridge (used by hardening firewall) |
| [inventories/prod/group_vars/lab_prod.yml](inventories/prod/group_vars/lab_prod.yml) | k3s version, SSSD client vars (`ldap_uri` → `192.168.20.7`, `ldap_search_base`, `ldap_bind_dn`; flip `sssd_ldap_enabled`) |
| [inventories/prod/group_vars/ldap_servers.yml](inventories/prod/group_vars/ldap_servers.yml) | OpenLDAP debconf: **`ldap_server_domain`** / org (`tafaust.org` → `dc=tafaust,dc=org`) |
| [inventories/prod/host_vars/](inventories/prod/host_vars/) | Per-node k3s role, agent join URL, LDAP overrides |

`ansible.cfg` pins inventory to `inventories/prod/hosts.yml`, so **`group_vars` / `host_vars` must live under `inventories/prod/`** (not the repo root).

## Suggested build order (k3s first)

1. **Proxmox**: Create **two VMs** (control plane + worker), cloud-init or manual install **Ubuntu 24.04**, one NIC on **`vmbr2`**, static DHCP or static IPs on `192.168.20.0/24`. Match names/IPs in `hosts.yml` + `host_vars/`.
2. **Bootstrap SSH**: Install your `ansible` user, **sudo**, and **authorized_keys** for your workstation (or password auth **only** until first hardening run if you set `common_hardening_disable_password_ssh: false` temporarily).
3. **Hardening** (opens UFW for lab CIDR + SSH, unattended upgrades, SSH hardening):

   ```bash
   cd ansible
   ansible-playbook playbooks/hardening.yml --limit lab_prod
   ```

   Run from a source address inside **`homelab_internal_cidr`**, or set `homelab_ssh_allow_extra_cidrs` in `host_vars` / `group_vars` for your VPN pool **before** enabling UFW.

4. **k3s control plane** (Flannel off, default network policy off, Traefik + ServiceLB off — ready for Cilium):

   ```bash
   ansible-playbook playbooks/k3s-node.yml --limit k3s-control-01
   ```

5. **Join token for workers**: On the server: `sudo cat /var/lib/rancher/k3s/server/node-token`. Either export for one run (`K3S_JOIN_TOKEN` is read by `host_vars/k3s-worker-01.yml`) or store in Ansible Vault and replace the lookup in host_vars.

   ```bash
   export K3S_JOIN_TOKEN='…token…'
   ansible-playbook playbooks/k3s-node.yml --limit k3s-worker-01
   ```

6. **LDAP server** on **`ldap-01`**: use Ansible — [playbooks/openldap-server.yml](playbooks/openldap-server.yml) (role `openldap_server`). Set **`ldap_admin_bind_password`** via Vault or `ansible-playbook … -e @secrets.yml` (never commit). Site config: **`ldap_server_domain: tafaust.org`** in [inventories/prod/group_vars/ldap_servers.yml](inventories/prod/group_vars/ldap_servers.yml) → suffix **`dc=tafaust,dc=org`**, admin **`cn=admin,dc=tafaust,dc=org`**, seeds **`ou=users|groups|services|kubernetes`**, then **OLC** (indices, limits, log, bm-uni-style ACLs). **TLS** not in role yet — add after install (see [identity/README.md](../identity/README.md)).

   ```bash
   ansible-playbook playbooks/openldap-server.yml --limit ldap_servers -e @/path/to/ldap-secrets.yml
   ```

7. **LDAP Web UI** on **`ldap-01`** (optional, after slapd): [playbooks/ldap-webui.yml](playbooks/ldap-webui.yml) — **phpLDAPadmin** via apt + Apache on port **8080** (lab/VPN UFW). Login with **`cn=admin,dc=tafaust,dc=org`** + admin password.

   ```bash
   ansible-playbook playbooks/ldap-webui.yml --limit ldap_servers
   ```

   UI: `http://192.168.20.7:8080/phpldapadmin/` (WireGuard/lab only).

8. **LDAP / SSSD** (optional, after directory exists): set `ldap_uri` (e.g. `ldaps://192.168.20.7/`), `ldap_search_base`, bind DN/password (Vault), optional `ldap_tls_cacert_pem`, then `sssd_ldap_enabled: true` in `group_vars/lab_prod.yml` or per-host. Run `playbooks/sssd-ldap.yml`.

9. **Infisical** on **`infisical-01`** (VM recommended): [playbooks/infisical-server.yml](playbooks/infisical-server.yml) — hardening + Docker Compose (Postgres, Redis, backend). Secrets: copy [infisical-secrets.example.yml](inventories/prod/group_vars/infisical_servers/infisical-secrets.example.yml) → `~/secrets/infisical-secrets.yml`.

   ```bash
   ansible-playbook playbooks/infisical-server.yml --limit infisical-01 -e @~/secrets/infisical-secrets.yml
   ```

   VPN source CIDR: `homelab_wireguard_site_cidr: 10.0.0.0/23` in [homelab.yml](inventories/prod/group_vars/all/homelab.yml). UI: `http://192.168.20.8` (set `infisical_site_url` if you add TLS/reverse proxy).

10. **Cilium**: Install from your GitOps flow or upstream docs on the cluster (not covered here).

## Full site playbook

```bash
ansible-playbook playbooks/site.yml --limit lab_prod
```

This runs hardening → SSSD (skipped until enabled) → k3s on `lab_prod`. **Agents need a join token** (see step 5) or the play fails on the worker.

## Variables (short)

| Variable | Where | Purpose |
|----------|--------|---------|
| `homelab_internal_cidr` | `inventories/prod/group_vars/all/homelab.yml` | UFW allow source; must match lab subnet |
| `homelab_ssh_allow_extra_cidrs` | `group_vars/all/homelab.yml` | VPN / remote site CIDRs for SSH (and restricted UFW) |
| `common_hardening_ufw_allow_lab_cidr_all` | `group_vars/ldap_servers.yml` etc. | `false` on LDAP = port-specific rules only |
| `common_hardening_ufw_allowed_tcp_ports` | `group_vars/ldap_servers.yml` | e.g. `[22, 389, 636]` when lab-wide allow is off |
| `k3s_version` | `group_vars/lab_prod.yml` | Pinned k3s (e.g. `v1.31.5+k3s1`) |
| `k3s_node_role` | `host_vars` | `server` or `agent` |
| `k3s_url` / `k3s_registration_token` | worker `host_vars` or env | Agent join |
| `ldap_admin_bind_password` | Vault / `-e @…` | **Required** for `openldap-server.yml` |
| `ldap_server_domain` | [group_vars/ldap_servers.yml](inventories/prod/group_vars/ldap_servers.yml) | DNS domain for debconf → `dc=…` suffix (here **`tafaust.org`**) |
| `openldap_create_demo_user` | `-e` / `host_vars` | Set `true` for optional `demo` posix user + group |
| `ldap_webui_listen_port` | `group_vars/ldap_servers.yml` | phpLDAPadmin Apache port (default **8080**); UFW allow |
| `ldap_webui_enabled` | `group_vars` / `-e` | Set `false` to skip [ldap-webui.yml](playbooks/ldap-webui.yml) |

Override example:

```bash
ansible-playbook playbooks/site.yml -e homelab_internal_cidr=10.0.0.0/24 --limit k3s-control-01
```

## Remote access

Reach `192.168.20.x` over **site-to-site WireGuard**. Your SSH **source** is often **not** in `homelab_internal_cidr` — set `homelab_wireguard_site_cidr` / `homelab_ssh_allow_extra_cidrs` in [homelab.yml](inventories/prod/group_vars/all/homelab.yml) (here **`10.0.0.0/23`**) **before** enabling UFW. See [../docs/runbooks/remote-access.md](../docs/runbooks/remote-access.md).

Always use the project venv (`source .venv/bin/activate`); Homebrew Ansible can break on the stdout callback.

## Hardening coverage (`common_hardening`)

| Area | Homelab role | [Medium guide](https://medium.com/@paulhoke/how-to-set-up-and-harden-a-new-ubuntu-24-04-server-1929ac72161f) | [CIS via Ubuntu USG](https://ubuntu.com/blog/hardening-automation-for-cis-benchmarks-now-available-for-ubuntu-24-04-lts) |
|------|--------------|--------|-----|
| apt safe upgrade | yes (`common_hardening_apt_upgrade`) | yes | partial |
| sudo user / SSH keys | manual bootstrap | yes | partial |
| sshd hardening | yes (template) | yes | partial |
| UFW / firewalld | yes (UFW on Debian; firewalld rich rules on SUSE) | yes | partial (ufw/nftables choice) |
| fail2ban | yes | yes | partial |
| unattended-upgrades | yes | yes | partial |
| auditd | yes (enable service) | yes | partial |
| AppArmor verify | yes | yes | partial |
| `/run/shm` noexec | yes | yes | partial |
| sysctl network | yes | yes | partial |
| swap / timezone / 2FA | no | optional | varies |
| full CIS rule set | no | no | **Ubuntu Pro + `usg fix`** |

**ldap_servers** group uses restricted UFW: TCP 22, 636, 8080 (phpLDAPadmin) from `homelab_internal_cidr` + `homelab_ssh_allow_extra_cidrs` only (no allow-all from lab).

### Post-hardening verify (on host or via Ansible ad hoc)

```bash
ssh ldap-01 'sudo ufw status verbose'
ssh ldap-01 'sudo fail2ban-client status sshd'
ssh ldap-01 'sudo auditctl -s | head -5'
ssh ldap-01 'sysctl net.ipv4.tcp_syncookies'
ssh ldap-01 'systemctl is-active apparmor'
```

From your laptop (WireGuard up): `ssh ldap-01` must succeed before running OpenLDAP playbook.

## Roles

| Role | Status |
|------|--------|
| `common_hardening` | Ubuntu/Debian: UFW, unattended upgrades, sshd/fail2ban/auditd/sysctl, optional apt upgrade |
| `sssd_ldap` | Ubuntu/Debian when `sssd_ldap_enabled: true` + `ldap_*` + Vault |
| `k3s_node` | Ubuntu/Debian: pinned `get.k3s.io` install, Cilium-oriented flags |
| `openldap_server` | Ubuntu/Debian on `ldap_servers`: `slapd` + base OUs + TLS (LDAPS) |
| `ldap_webui` | Ubuntu/Debian on `ldap_servers`: phpLDAPadmin (apt + Apache) |
| `infisical_server` | Ubuntu/Debian on `infisical_servers`: Docker Compose (Postgres, Redis, Infisical) |
