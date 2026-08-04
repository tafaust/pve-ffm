# Lab staging

Use `lab_staging` in [ansible/inventories/prod/hosts.yml](../ansible/inventories/prod/hosts.yml) for LXCs/VMs that mirror production roles with smaller disks and relaxed firewall rules.

Future GitOps: add `clusters/staging/` with the same Argo layout but **pinned older chart versions** and **fewer replicas**. Keep staging off production Postgres clusters; clone schemas with anonymized data when needed.
