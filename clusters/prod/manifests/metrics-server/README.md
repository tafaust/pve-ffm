# metrics-server (Kustomize)

Production overlay patches upstream manifests to allow **insecure kubelet TLS** (common on lab clusters with self-signed kubelets). Tighten this for real production (proper kubelet CA).

## Build

```bash
kubectl kustomize clusters/prod/manifests/metrics-server/overlays/production
```

Upstream pin: `v0.7.2` `components.yaml` (bump deliberately when upgrading).
