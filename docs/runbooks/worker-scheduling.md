# Worker scheduling (keep the control plane light)

App workloads run on **workers**. The control plane (`k3s-control-01`) stays for etcd/API plus DaemonSets that must run on every node (Cilium agent, Longhorn manager/engine).

Label key/value (Ansible + Helm must match):

```yaml
homelab.tafaust.org/role: worker
```

## Ansible

- Control-plane taint: `node-role.kubernetes.io/control-plane=true:NoSchedule` in `k3s_server_install_flags` (`ansible/roles/k3s_node/defaults/main.yml`). Re-applied on each `k3s_node` run.
- Worker labels: `k3s_node_labels` in `host_vars/k3s-worker-*.yml`. Join flags plus a post-join `kubectl label` delegated to `k3s-control-01`.
- Group vars: `homelab_worker_node_label_key` / `homelab_worker_node_label_value` in `ansible/inventories/prod/group_vars/lab_prod.yml`.

Apply:

```bash
cd ansible
ansible-playbook playbooks/k3s-node.yml --limit lab_prod
```

## GitOps

Platform Helm apps under `clusters/prod/apps/platform/` set:

```yaml
nodeSelector:
  homelab.tafaust.org/role: worker
```

Same selector on the metrics-server overlay (`clusters/prod/manifests/metrics-server/overlays/production/patch-deployment.yaml`) and Keycloak values.

| Component | On control plane? |
|-----------|-------------------|
| Cilium agent, Longhorn manager/engine (DaemonSets) | Yes — every node |
| Cilium operator, Longhorn UI, ingress-nginx, cert-manager, ESO, SeaweedFS, StackGres, Keycloak, metrics-server, Kubero | No — workers only |
| Argo CD (upstream install, not in Git yet) | Patch to workers (below) |

After Argo syncs, delete pods still bound to `k3s-control-01` (except DaemonSets) so they reschedule:

```bash
export KUBECONFIG=~/.kube/configs/pve-ffm.yaml
kubectl get pods -A --field-selector spec.nodeName=k3s-control-01
```

## Argo CD → workers

Argo is installed from the upstream manifest ([argocd-bootstrap.md](argocd-bootstrap.md)), which tolerates the control-plane taint. Pin it with `nodeSelector` (workers already have the label; taint tolerations on workers are harmless):

```bash
export KUBECONFIG=~/.kube/configs/pve-ffm.yaml
for d in argocd-server argocd-repo-server argocd-dex-server \
         argocd-applicationset-controller argocd-notifications-controller argocd-redis; do
  kubectl -n argocd patch deploy "$d" --type merge -p \
    '{"spec":{"template":{"spec":{"nodeSelector":{"homelab.tafaust.org/role":"worker"}}}}}'
done
kubectl -n argocd patch sts argocd-application-controller --type merge -p \
  '{"spec":{"template":{"spec":{"nodeSelector":{"homelab.tafaust.org/role":"worker"}}}}}'
```

Re-apply after any `kubectl apply -f …/argocd/…/install.yaml`. Long-term: manage Argo with a Helm `Application` in this repo.

## Related

- Disk pressure / Failed-pod purge: [cluster-health.md](cluster-health.md)
- Homelab apps / Dokploy-style PaaS: [homelab-apps.md](homelab-apps.md)
