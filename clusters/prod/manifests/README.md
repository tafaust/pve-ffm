# Scaffold manifests for Argo `Application` sources

| Path | Purpose |
|------|---------|
| [infisical/](infisical/) | Namespace-only stub until Infisical Helm is wired |
| [metrics-server/](metrics-server/) | Kustomize overlay on upstream `components.yaml` (kubelet TLS lab patch) |
| [keycloak/](keycloak/) | Kustomize + **codecentric/keycloakx** Helm (Argo `kustomize.buildOptions: --enable-helm` on `argocd-cm`) |

**SeaweedFS** is deployed from the upstream Helm chart via [apps/platform/seaweedfs.yaml](../apps/platform/seaweedfs.yaml), not this tree.

Replace Infisical stubs with Helm/OCI when you pick chart versions.
