# Storage — future home (scaffold notes)

## Backups (restic / kopia)

- Use **restic** or **kopia** with **object storage** (SeaweedFS S3-compatible, or cloud) for encrypted off-node backups.
- Scope: etcd snapshots (if self-managed), Postgres volumes (StackGres backups + logical dumps), and application PVC exports where needed.

## Postgres operator (StackGres)

- StackGres provides opinionated HA Postgres; pair with **scheduled backups** to object storage.
- Keep DB **inside** the latency envelope of your cluster; do not stretch primary writes across WAN.

## Longhorn caution

**Avoid Longhorn (or any synchronous replicated block storage) across WAN links.** Split-brain, latency amplification, and rebuild traffic will dominate. Use **local** or **zonal** storage for Kubernetes nodes, and async backup to cold storage instead.

## TODO (implement)

- Volume snapshot classes + backup Jobs.
- SeaweedFS replication / bucket lifecycle policies.
