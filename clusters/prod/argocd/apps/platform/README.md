# Platform Argo `Application` bundle

This directory is the **Kustomize root** synced by [root-app.yaml](../root-app.yaml). Each file is one Argo `Application` (Helm chart or in-repo path).

## Observability (SigNoz)

- [signoz.yaml](signoz.yaml) — official `signoz/signoz` chart (`https://charts.signoz.io`), namespace `observability`, Helm values from `clusters/prod/manifests/signoz/` via `spec.sources` (Argo CD 2.6+).
- [signoz-k8s-infra.yaml](signoz-k8s-infra.yaml) — `signoz/k8s-infra` chart for cluster telemetry and pod logs.
- [opentelemetry-operator.yaml](opentelemetry-operator.yaml) — optional OpenTelemetry Operator (CRDs / Instrumentation); remove from [kustomization.yaml](kustomization.yaml) if unused.

See [docs/runbooks/signoz.md](../../../../../docs/runbooks/signoz.md).

When you add many clusters or envs, replace static YAML with a generator, for example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: platform-from-git
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - matrix:
        generators:
          - git:
              repoURL: https://github.com/REPLACE_ME/pve-ffm.git
              revision: main
              directories:
                - path: clusters/prod/argocd/apps/workloads/*
          - list:
              elements:
                - cluster: in-cluster
                  url: https://kubernetes.default.svc
  template:
    metadata:
      name: '{{.path.basename}}'
    spec:
      project: homelab
      source:
        repoURL: '{{.repoURL}}'
        targetRevision: '{{.revision}}'
        path: '{{.path.path}}'
      destination:
        server: '{{.cluster}}'
        namespace: apps
```

Validate against your Argo CD version before applying; keep `workloads/` populated or narrow the `directories` glob.
