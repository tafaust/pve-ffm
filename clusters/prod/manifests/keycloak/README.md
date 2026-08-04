# Keycloak (Kustomize + Helm)

Uses the **codecentric/keycloakx** Helm chart via Kustomize’s built-in Helm inflation (**not** Bitnami).

## Build (requires Helm inflation)

Argo CD is configured in the `Application` with `kustomize.buildOptions: --enable-helm`. For local renders:

```bash
kubectl kustomize --enable-helm clusters/prod/manifests/keycloak/overlays/production
```

Tune `values.yaml` per environment (database, hostname, resources). Do not commit secrets.
