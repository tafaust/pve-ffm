# Homelab apps on k3s (Dokploy replacement)

Do **not** install Dokploy on this cluster. Dokploy is a Docker Compose / Swarm PaaS. This lab is GitOps on k3s (Argo CD + Longhorn + ingress-nginx + cert-manager).

## Recommendation: Kubero

Closest Dokploy-like UX that is **Kubernetes-native**: Git push or image deploy, templates (WordPress, Grafana, …), add-ons (Postgres, Redis), review apps. Two pods (UI + operator); data in-cluster.

- Docs: https://www.kubero.dev/
- Chart: https://github.com/kubero-dev/kubero

Install later as an Argo `Application` under `clusters/prod/apps/` with:

```yaml
nodeSelector:
  homelab.tafaust.org/role: worker
```

Keep Argo CD as source of truth for **platform**. Use Kubero for **userspace** apps you would have clicked together in Dokploy.

### Alternatives (skip for now)

| Tool | Why not first |
|------|----------------|
| Coolify / Dokploy | Docker/Swarm, not k3s |
| Devtron | Heavy (own Postgres/Redis, many controllers) |
| Cyclops | Nice template UI; weaker Git-push PaaS |
| Portainer / Headlamp | Cluster UI, not an app PaaS |
| Raw Argo Applications | Best long-term; more YAML than Dokploy |

## Migrate one Dokploy app

Wait until [cluster-health.md](cluster-health.md) “Ready for apps” is true. Then:

1. Stateless service first (no volume).
2. `Deployment` + `Service` + `Ingress` + `Certificate` (cert-manager).
3. `nodeSelector: homelab.tafaust.org/role: worker`.
4. Argo `Application` pointing at a path under `clusters/prod/manifests/<app>/`.
5. Cut DNS when Ingress + TLS work. Leave Dokploy running until then.

Stateful next: Longhorn PVC (`defaultReplicaCount: 2` needs both workers). Databases: StackGres once that operator is Healthy, or a single Longhorn Postgres for tiny apps.

## Platform you already have

| Need | Component |
|------|-----------|
| GitOps | Argo CD |
| Ingress / TLS | ingress-nginx + cert-manager |
| Block storage | Longhorn |
| Object storage | SeaweedFS |
| Secrets | Infisical + external-secrets |
| Identity | Keycloak (LDAP federation) |
