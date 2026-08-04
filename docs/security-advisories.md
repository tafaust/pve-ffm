# Security advisory checklist (manual / RSS)

Subscribe or poll periodically:

| Component | Where |
|-----------|--------|
| k3s | <https://github.com/k3s-io/k3s/security> |
| Cilium | <https://github.com/cilium/cilium/security> |
| Argo CD | <https://github.com/argoproj/argo-cd/security> |
| cert-manager | <https://github.com/cert-manager/cert-manager/security> |
| StackGres | <https://stackgres.io/doc/> + GitHub advisories |
| SeaweedFS | <https://github.com/seaweedfs/seaweedfs> |
| Keycloak | <https://www.keycloak.org/security> |
| NetBird | <https://github.com/netbirdio/netbird/security> |
| Infisical | <https://github.com/Infisical/infisical/security> |
| Plane / apps | upstream GitHub Security tab |
| Ubuntu / Debian / SUSE | USN, DSA, SUSE security announcements |

**Pinning:** use `targetRevision` / image digests in Git; Renovate opens PRs (see `renovate.json`).
