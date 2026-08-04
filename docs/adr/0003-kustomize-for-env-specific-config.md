# ADR 0003 — Kustomize for environment-specific Kubernetes config

## Status

Accepted

## Context

Platform components differ per environment (for example kubelet TLS settings for metrics-server, Keycloak hostname and database wiring). Duplicating entire Helm `values.yaml` blobs across forks is error-prone.

## Decision

- Use **Kustomize bases and overlays** under `clusters/prod/manifests/<app>/` when behavior must diverge by environment or tenant.
- Point Argo CD `Application` resources at the **overlay path** (`source.path`), not at a monolithic shared directory.
- Keep Helm where upstream maintenance is strong; **wrap** Helm with Kustomize when you need overlays (for example Keycloak via `kubectl kustomize --enable-helm` / Argo `buildOptions`).

## Consequences

- Local validation uses `kubectl kustomize …` (and `--enable-helm` where Helm inflation is used).
- Repo layout stays explicit: `base/` vs `overlays/<env>/`.

## Links

- [kubectl kustomize documentation](https://kubectl.docs.kubernetes.io/references/kustomize/)
