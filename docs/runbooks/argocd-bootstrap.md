# Argo CD bootstrap (k3s-homelab)

Argo CD is the **only** supported install path for platform apps (Cilium, Longhorn, ingress, …). Do not `helm install` platform charts by hand after bootstrap — register them as `Application` objects under `clusters/prod/apps/platform/`.

## Prerequisites

- k3s control plane reachable (`KUBECONFIG=~/.kube/configs/pve-ffm.yaml`)
- Git remote pushed (`https://github.com/tafaust/pve-ffm.git`, branch `main`) for in-repo Kustomize apps

## 1. Install Argo CD (once)

```bash
export KUBECONFIG=~/.kube/configs/pve-ffm.yaml
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
```

Enable Kustomize `--enable-helm` for Keycloak overlay:

```bash
kubectl patch configmap argocd-cm -n argocd --type merge \
  -p '{"data":{"kustomize.buildOptions":"--enable-helm"}}'
kubectl -n argocd rollout restart deploy/argocd-repo-server
kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=120s
```

UI (lab only):

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
# https://localhost:8080 — admin / initial password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## 2. Migrate off manual Helm (if needed)

If Cilium/Longhorn were installed with `helm install`, remove Helm ownership so Argo can manage releases:

```bash
helm uninstall longhorn -n longhorn-system
helm uninstall cilium -n kube-system
kubectl annotate storageclass local-path storageclass.kubernetes.io/is-default-class=false --overwrite
```

Brief CNI outage until Argo syncs Cilium (wave `-30`).

## 3. Register platform apps

**AppProject** + child `Application` CRs:

```bash
kubectl apply -n argocd -f clusters/prod/argocd/project-default.yaml
kubectl apply -k clusters/prod/apps/platform
```

Optional app-of-apps (keeps `clusters/prod/apps/platform/` in sync with Git):

```bash
kubectl apply -n argocd -f clusters/prod/argocd/root-app.yaml
```

## 4. Sync order (sync-wave)

| Wave | App |
|------|-----|
| -30 | cilium |
| -20 | longhorn |
| -10 | cert-manager |
| 0 | metrics-server |
| 10 | external-secrets |
| 20 | stackgres-operator |
| 30 | ingress-nginx |
| 40 | seaweedfs, infisical, keycloak |
| 45 | kubero-operator |
| 50 | kubero (UI) |

Cilium must be Healthy before workloads that need pod networking. Longhorn needs Cilium + `open-iscsi` on nodes (Ansible `k3s_node` role).

## 5. Verify

```bash
kubectl -n argocd get applications
kubectl get nodes
kubectl get sc
kubectl -n kube-system get pods -l k8s-app=cilium
kubectl -n longhorn-system get pods
```

## Notes

- Argo CD itself is **not** self-managed in this repo (upstream install manifest). Pin it to workers after install — [worker-scheduling.md](worker-scheduling.md).
- Git-sourced apps fail until `main` is pushed to the configured `repoURL`.
- Default StorageClass: Longhorn chart sets `longhorn` default; demote k3s `local-path` once (see step 2).
