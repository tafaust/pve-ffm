# ADR 0004 — Argo CD app-of-apps with a single root Application

## Status

Accepted

## Context

We need a GitOps entry that bootstraps many platform controllers without copying paste errors, while staying readable for small clusters.

## Decision

- Maintain **one** root `Application` (`clusters/prod/argocd/root-app.yaml`) that syncs a **Kustomize directory** of child `Application` objects (`clusters/prod/apps/platform/`).
- Keep the `AppProject` in `clusters/prod/argocd/project-default.yaml` (forks tighten RBAC scopes).
- Prefer static child `Application` YAML until complexity justifies `ApplicationSet`.

## Consequences

- Bootstrap is two `kubectl apply` steps after Argo CD install (project + root app).
- Child apps can mix Helm charts and in-repo Kustomize paths consistently.

## Links

- [Argo CD app-of-apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern)
