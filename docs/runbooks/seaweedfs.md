# SeaweedFS (S3-compatible)

Deployed via Argo CD (`clusters/prod/apps/platform/seaweedfs.yaml`) from the official Helm chart. PVCs use the **longhorn** StorageClass.

## Access

After sync, S3 API is exposed inside the cluster (chart `s3.enabled: true`). Use the filer/S3 service DNS name from:

```bash
kubectl -n seaweedfs get svc
```

Expose externally with **ingress-nginx** + **cert-manager** when ready; keep admin APIs off the public internet.

## StackGres / backups

Point StackGres `SGObjectStorage` at the SeaweedFS S3 endpoint; credentials via **ExternalSecrets**. See [stackgres-seaweedfs-backup.md](stackgres-seaweedfs-backup.md).

## Ops

- Pin `targetRevision` after smoke tests ([renovate.md](../renovate.md)).
- Scale `master` / `volume` / `filer` replicas when you add worker nodes.
