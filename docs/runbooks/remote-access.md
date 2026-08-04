# Remote access

## WireGuard underlay (site-to-site)

Typical pattern: **FRITZ!Box** (or other edge) builds a **WireGuard** tunnel to the datacenter router/firewall. Inside the tunnel you route **`192.168.20.0/24`** (lab LAN). Your workstation then:

1. Joins the same VPN (road-warrior profile or routed site-to-site), **or**
2. SSH jumps via a bastion that already sits on the lab network.

**Ansible** should target `ansible_host` values in `192.168.20.0/24` only when your control node can reach that subnet (VPN up). The playbooks do not configure consumer routers.

### UFW and SSH source addresses

Routing to `192.168.20.x` does **not** mean your laptop’s IP is in `192.168.20.0/24`. Over site-to-site WireGuard the **source** seen on lab VMs is usually your **remote site CIDR** (here `10.0.0.0/8` in [ansible/inventories/prod/group_vars/all/homelab.yml](../../ansible/inventories/prod/group_vars/all/homelab.yml) as `homelab_ssh_allow_extra_cidrs`).

Before tightening firewall rules, confirm from an active SSH session on the target host:

```bash
sudo ss -tn state established sport = :22
```

Re-run [ansible/playbooks/hardening.yml](../../ansible/playbooks/hardening.yml) after changing CIDRs. Keep Proxmox/console access until `ssh` from your usual path works.

## Optional NetBird overlay

**NetBird** (or Tailscale) adds a mesh overlay when you cannot maintain static WireGuard peers per device. Treat it as **additive**:

- Keep WireGuard underlay for stable site routing.
- Use NetBird for ad-hoc admin machines and OIDC/LDAP test clients.

LDAP-related notes: expose directory **TLS only**; avoid plaintext LDAP across WAN. For NetBird peers, still prefer hitting LDAP via the **internal** lab VIP/DNS name once inside the mesh.

## OIDC chain

User-facing apps (Grafana, Argo CD, etc.) should use **OIDC → Keycloak** (realm clients) with LDAP as Keycloak’s user federation backend. Avoid issuing long-lived passwords to shared admin accounts; prefer SSO groups mapped to RBAC.

See [identity/README.md](../identity/README.md) for DIT sketch.
