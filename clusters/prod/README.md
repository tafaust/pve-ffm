# clusters/prod — Argo CD (GitOps)

**Argo CD** is the default GitOps tool; [Rancher Fleet](https://fleet.rancher.io/) can consume the same manifests with different bootstrap wiring (see layout table).

## Bootstrap (once per cluster)

1. Install Argo CD — [docs/runbooks/argocd-bootstrap.md](../../docs/runbooks/argocd-bootstrap.md) (upstream manifest; not vendored here).
2. Ensure `repoURL` in Git-sourced `Application` objects matches your fork (default: `https://github.com/tafaust/pve-ffm.git`).
3. Apply the AppProject, then platform apps (or root app):

```bash
kubectl apply -n argocd -f clusters/prod/argocd/project-default.yaml
kubectl apply -n argocd -f clusters/prod/argocd/root-app.yaml
```

The root `Application` (`platform-apps`) syncs **`clusters/prod/apps/platform/`** (Kustomize), which expands into child `Application` CRs (app-of-apps). See [argocd/README.md](argocd/README.md) and [ADR 0004](../../docs/adr/0004-argocd-app-of-apps.md).

**ApplicationSet** (optional): add a generator (Git directories, cluster matrix, etc.) when you grow past static YAML; see [Argo CD ApplicationSet](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/).

## Ingress

Placeholders use **ingress-nginx** with **cert-manager**. **Traefik** is a fine alternative — swap the Helm `repoURL`/`chart` in the ingress `Application`.

## Layout

| Path | Content |
|------|---------|
| [argocd/](argocd/) | `AppProject` ([project-default.yaml](argocd/project-default.yaml)), [root-app.yaml](argocd/root-app.yaml) |
| [apps/platform/](apps/platform/) | Platform `Application` manifests (Helm + in-repo Kustomize paths) |
| [manifests/](manifests/) | Kustomize bases/overlays (SeaweedFS via Helm Argo app; Infisical stubs; metrics-server + Keycloak overlays) |
| [platform/](platform/) | Reserved for shared patches / notes |

Pin `targetRevision` after smoke tests; enable Renovate ([renovate.json](../../renovate.json), [docs/renovate.md](../../docs/renovate.md)).

## Kustomize checks

```bash
kubectl kustomize clusters/prod/apps/platform
kubectl kustomize clusters/prod/manifests/metrics-server/overlays/production
kubectl kustomize --enable-helm clusters/prod/manifests/keycloak/overlays/production
```

## Staging

Mirror this layout under `clusters/staging/` later; see [docs/runbooks/staging.md](../../docs/runbooks/staging.md).
