# Cluster health (k3s-homelab)

Context: `KUBECONFIG=~/.kube/configs/pve-ffm.yaml` ([kubeconfig.md](kubeconfig.md)). Control plane SSH: `thomas@192.168.20.10`.

## DiskPressure

Kubelet sets `DiskPressure` when free space on `/` drops under ~10–15%. Evicted pods stay in the API; they do **not** free disk. k3s uses **kine/SQLite** (or etcd) under `/var/lib/rancher/k3s/server/db` — thousands of Failed pods bloat that file.

`crictl rmi --prune` / Docker prune barely help (containerd images are small vs the DB).

### Unused LVM on the control plane

The VM disk can be larger than the mounted LV. Check before growing Proxmox:

```bash
ssh thomas@192.168.20.10 'sudo vgs; sudo lvs; df -h /'
```

If `VFree` is non-zero, extend in place (online):

```bash
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

Kubelet caches capacity. If `DiskPressure` stays True while `df` looks healthy, restart k3s (brief API blip):

```bash
sudo systemctl restart k3s
```

Then drop a stale taint if kubelet left it:

```bash
kubectl taint node k3s-control-01 node.kubernetes.io/disk-pressure:NoSchedule-
```

Keep the control-plane taint.

### Failed-pod purge

Unbounded `kubectl get pods -A --field-selector=status.phase=Failed` is slow. Chunk deletes (25–50). k3s kubectl may not support `--limit`; use `head`:

```bash
ssh thomas@192.168.20.10 'bash -s' <<'EOF'
chunk=25
for ns in argocd longhorn-system cert-manager ingress-nginx seaweedfs; do
  while true; do
    mapfile -t pods < <(sudo k3s kubectl get pods -n "$ns" --field-selector=status.phase=Failed -o name | head -n "$chunk")
    [ ${#pods[@]} -eq 0 ] && break
    sudo k3s kubectl delete "${pods[@]}" -n "$ns" --grace-period=0 --force --request-timeout=60s
  done
done
EOF
```

kine compact runs in the k3s log (`COMPACT deleted …`). Do not `etcdctl defrag` with only a few GB free — it copies the DB.

## Ready for apps

- Three nodes Ready, `DiskPressure=False`
- Control-plane taint present; workers labeled `homelab.tafaust.org/role=worker`
- Failed pods near zero in `argocd` / `longhorn-system` / `ingress-nginx`
- Platform Argo apps Healthy (Cilium, Longhorn, cert-manager, ingress-nginx)

See [worker-scheduling.md](worker-scheduling.md) and [homelab-apps.md](homelab-apps.md).
