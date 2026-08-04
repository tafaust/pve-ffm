# Argo CD bootstrap (this folder)

| File | Purpose |
|------|---------|
| [project-default.yaml](project-default.yaml) | `AppProject` with permissive defaults — **forks should tighten** `sourceRepos` / `destinations` for production |
| [root-app.yaml](root-app.yaml) | Single **app-of-apps** `Application` (Kustomize) → [`../apps/platform/`](../apps/platform/) |

Apply order (once Argo CD is installed in `argocd`):

```bash
kubectl apply -n argocd -f clusters/prod/argocd/project-default.yaml
kubectl apply -n argocd -f clusters/prod/argocd/root-app.yaml
```

See [ADR 0004](../../docs/adr/0004-argocd-app-of-apps.md) and [clusters/prod/README.md](../README.md).
