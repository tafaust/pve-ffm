# Platform Argo `Application` bundle

This directory is the **Kustomize root** synced by [root-app.yaml](../argocd/root-app.yaml). Each file is one Argo `Application` (Helm chart or in-repo Kustomize path).

## ApplicationSet (optional)

When you add many clusters or tenants, consider an `ApplicationSet` generator (Git directories, cluster matrix, …). Keep static YAML while the fleet is small — see [ADR 0004](../../../docs/adr/0004-argocd-app-of-apps.md).

Example matrix snippet (adapt to your repo URL and paths):

```yaml
spec:
  goTemplate: true
  generators:
    - matrix:
        generators:
          - git:
              repoURL: https://github.com/YOUR_ORG/pve-ffm.git
              revision: main
              directories:
                - path: clusters/prod/apps/workloads/*
          - list:
              elements:
                - cluster: in-cluster
                  url: https://kubernetes.default.svc
  template:
    metadata:
      name: '{{.path.basename}}'
    spec:
      project: platform
      source:
        repoURL: '{{.repoURL}}'
        targetRevision: '{{.revision}}'
        path: '{{.path.path}}'
      destination:
        server: '{{.url}}'
        namespace: apps
```

Validate against your Argo CD version before applying.
