# Kubero (Dokploy-like PaaS on k3s)

Operator + UI, GitOps via Argo (`clusters/prod/apps/platform/kubero-operator.yaml`, `kubero.yaml`).

- Operator: upstream `deploy/operator.yaml` + worker `nodeSelector`
- UI: Helm chart `helm-charts/kubero` from [kubero-operator](https://github.com/kubero-dev/kubero-operator), Longhorn PVCs, workers only
- Ingress off until a hostname exists — [homelab-apps.md](../../../../docs/runbooks/homelab-apps.md)

```bash
kubectl kustomize clusters/prod/manifests/kubero/operator
```
