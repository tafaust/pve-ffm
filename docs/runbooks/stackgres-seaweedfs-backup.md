# StackGres backups to SeaweedFS

After SeaweedFS + StackGres operator are running:

1. Create `SGObjectStorage` or backup configuration per [StackGres backup documentation](https://stackgres.io/doc/latest/install/prerequisites/backups/) for your version.
2. Use **S3-compatible** endpoint = SeaweedFS internal service URL; credentials from **ExternalSecret**.
3. Test restore drill on staging `SGCluster` before relying on prod backups.
