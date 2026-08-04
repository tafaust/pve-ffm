# Userspace applications (Argo CD)

Add one `Application` per workload (or one app pointing to a Kustomize/Helm umbrella chart).

| App | Upstream | Notes |
|-----|----------|--------|
| **Immich** | <https://immich.app/docs/install/kubernetes> | Postgres via StackGres; S3 (SeaweedFS); OIDC → Keycloak |
| **Paperless** | community Helm / official compose port | OIDC; Postgres StackGres |
| **Vaultwarden** | <https://github.com/dani-garcia/vaultwarden> chart variants | OIDC if enabled in image; often single SQLite/PG |
| **Plane** | <https://developers.plane.so/self-hosting/methods/kubernetes> | Postgres + Redis; OIDC per Plane docs |
| **Wiki.js** | Helm `wiki` / operator | Alternative to Plane for wiki-first |

## Pattern

1. Create namespace + `NetworkPolicy` defaults.
2. `SGCluster` (StackGres) or reuse shared cluster per blast-radius policy.
3. **ExternalSecret** pulls DB password from Infisical.
4. **Keycloak** OIDC client + redirect URIs for app hostname.

Example stub (uncomment and fix `repoURL` when ready):

```yaml
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: immich
#   namespace: argocd
# spec:
#   project: platform
#   source:
#     repoURL: https://github.com/immich-app/immich-charts
#     path: charts/immich
#     targetRevision: main
#   destination:
#     server: https://kubernetes.default.svc
#     namespace: immich
```

Keep chart versions **pinned**; let Renovate open upgrade PRs.
