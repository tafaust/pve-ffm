# Homelab apps on k3s (Dokploy replacement)

Do **not** install Dokploy on this cluster. Dokploy is a Docker Compose / Swarm PaaS. This lab is GitOps on k3s (Argo CD + Longhorn + ingress-nginx + cert-manager).

## Kubero (provisioned)

Kubernetes-native PaaS: Git push or image deploy, templates, add-ons (Postgres, Redis). Argo apps:

- `kubero-operator` — CRDs + controller (`clusters/prod/manifests/kubero/operator/`)
- `kubero` — UI Helm chart from [kubero-operator](https://github.com/kubero-dev/kubero-operator), workers + Longhorn

Docs: https://www.kubero.dev/

Keep Argo CD as source of truth for **platform**. Use Kubero for **userspace** apps you would have clicked together in Dokploy.

Helm does **not** create `kubero-secrets`. Create once (not in Git):

```bash
export KUBECONFIG=~/.kube/configs/pve-ffm.yaml
kubectl -n kubero create secret generic kubero-secrets \
  --from-literal=KUBERO_WEBHOOK_SECRET="$(openssl rand -hex 16)" \
  --from-literal=KUBERO_SESSION_KEY="$(openssl rand -hex 16)" \
  --from-literal=KUBERO_ADMIN_USERNAME=admin \
  --from-literal=KUBERO_ADMIN_PASSWORD="$(openssl rand -base64 18)"
```

Read the admin password:

```bash
kubectl -n kubero get secret kubero-secrets -o jsonpath='{.data.KUBERO_ADMIN_PASSWORD}' | base64 -d; echo
```

### Access (no Ingress yet)

```bash
export KUBECONFIG=~/.kube/configs/pve-ffm.yaml
kubectl -n kubero port-forward svc/kubero 2000:2000
# http://localhost:2000
```

Enable Ingress later in `clusters/prod/apps/platform/kubero.yaml` (`ingress.enabled`, hostname, cert-manager annotations). Do not expose the UI on the public internet without auth.

### Alternatives (skip)

| Tool | Why not first |
|------|----------------|
| Coolify / Dokploy | Docker/Swarm, not k3s |
| Devtron | Heavy (own Postgres/Redis, many controllers) |
| Cyclops | Nice template UI; weaker Git-push PaaS |
| Portainer / Headlamp | Cluster UI, not an app PaaS |
| Raw Argo Applications | Best long-term; more YAML than Dokploy |

## Migrate one Dokploy app

Wait until [cluster-health.md](cluster-health.md) “Ready for apps” is true. Then either click-deploy in Kubero or:

1. Stateless service first (no volume).
2. `Deployment` + `Service` + `Ingress` + `Certificate` (cert-manager).
3. `nodeSelector: homelab.tafaust.org/role: worker`.
4. Argo `Application` pointing at a path under `clusters/prod/manifests/<app>/`.
5. Cut DNS when Ingress + TLS work. Leave Dokploy running until then.

Stateful next: Longhorn PVC (`defaultReplicaCount: 2` needs both workers). Databases: Kubero add-on, StackGres once that operator is Healthy, or a single Longhorn Postgres for tiny apps.

## Platform you already have

| Need | Component |
|------|-----------|
| GitOps | Argo CD |
| App PaaS | Kubero |
| Ingress / TLS | ingress-nginx + cert-manager |
| Block storage | Longhorn |
| Object storage | SeaweedFS |
| Secrets | Infisical + external-secrets |
| Identity | Keycloak (LDAP federation) |
