# SigNoz (homelab)

This repo deploys **SigNoz** from the official Helm repository (`https://charts.signoz.io`, chart **`signoz`**, pinned in [clusters/prod/argocd/apps/platform/signoz.yaml](../../clusters/prod/argocd/apps/platform/signoz.yaml)) into namespace **`observability`**, with optional **`k8s-infra`** for cluster telemetry. Install overview: [Kubernetes](https://signoz.io/docs/install/kubernetes/).

## Accessing the UI (VPN / no public ingress)

Helm values keep **`signoz.ingress.enabled: false`**. Reach the UI by one of:

- **`kubectl port-forward`** (quick):  
  `kubectl -n observability port-forward svc/signoz 8080:8080`  
  then open `http://localhost:8080`.
- **Private ingress**: enable `signoz.ingress` in your overlay and restrict access (NetworkPolicy, internal DNS, mTLS) — not configured in-repo by default.

## Single-node vs HA

- **Homelab / single-node**: chart defaults in `clusters/prod/manifests/signoz/base/values.yaml` use **one** ClickHouse shard/replica and **one** ZooKeeper replica (`clickhouse.layout`, `clickhouse.zookeeper.replicaCount`). Expect all components on one node; size CPU/memory/PVC accordingly.
- **HA / production-style**: follow upstream SigNoz sizing and increase ClickHouse layout, collector replicas, and storage; expect multiple nodes and anti-affinity. See SigNoz documentation for current recommendations.

## Retention

Telemetry retention is a combination of **PVC size**, **ClickHouse TTL / merge settings**, and **SigNoz product configuration** (see upstream docs for your chart `appVersion`). There is no single static knob in this repo; after install, confirm disk usage on the ClickHouse PVC and adjust `clickhouse.persistence.size` in `overlays/prod/values.yaml` plus SigNoz settings as needed.

## Backup warning

SigNoz’s durable state is primarily **ClickHouse data on PVCs** (and smaller SQLite PVC for the query layer where enabled). **Velero snapshots, CSI volume snapshots, or recurring `clickhouse-backup`-style jobs** are your responsibility; GitOps manifests do not back up telemetry. Test restores before relying on history for incident forensics.

## Applications → OTLP (cluster-internal)

Applications should export **OTLP** to the collector **inside the cluster**:

| Protocol | Service | Port |
|----------|---------|------|
| OTLP gRPC | `signoz-otel-collector.observability.svc.cluster.local` | `4317` |
| OTLP HTTP | `signoz-otel-collector.observability.svc.cluster.local` | `4318` |

Example environment variables for a pod:

```text
OTEL_EXPORTER_OTLP_ENDPOINT=http://signoz-otel-collector.observability.svc.cluster.local:4317
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
```

For HTTP/protobuf, use port **4318** and set the exporter protocol per your SDK.

**Security**: in-cluster OTLP is typically **plaintext** unless you add TLS at the collector; restrict with NetworkPolicy and service placement. For mTLS or tail sampling at edge, see current SigNoz collector docs.

## OpenTelemetry Operator (optional)

The platform bundle includes [opentelemetry-operator.yaml](../../clusters/prod/argocd/apps/platform/opentelemetry-operator.yaml) so you can use **Instrumentation** and **OpenTelemetryCollector** CRDs. Auto-instrumentation **varies by language and version**; read the operator docs before assuming zero-code instrumentation: [OpenTelemetry Operator](https://opentelemetry.io/docs/kubernetes/operator/).

To skip the operator, remove that file from `clusters/prod/argocd/apps/platform/kustomization.yaml`.

## Cluster “itself” (nodes, kubelet, workloads)

The **`signoz/k8s-infra`** chart ([docs](https://signoz.io/docs/opentelemetry-collection-agents/k8s/k8s-infra/)) ships collectors that scrape **kubelet** stats (container/pod/node metrics via the kubelet API), **host metrics** (node-exporter–style host telemetry through OTel receivers), **cluster metrics** (API-server–derived signals in the presets), optional **Kubernetes events**, and **pod logs**. Enable or narrow presets in `clusters/prod/manifests/signoz/k8s-infra/overlays/prod/values.yaml` per upstream values.

### k3s notes

- k3s uses the **kubelet** on port **10250**; the chart defaults generally use **serviceAccount auth** and **`insecureSkipVerify: true`** for kubelet scraping — verify against your hardening policy.
- Default log paths under `/var/log/pods` match typical container runtimes; if scraping fails after CIS-hardening, compare with [k8s-infra troubleshooting](https://signoz.io/docs/opentelemetry-collection-agents/k8s/k8s-infra/) for your k3s version.

## Chart pins

Re-pin after smoke tests:

```bash
helm repo add signoz https://charts.signoz.io && helm repo update signoz
helm search repo signoz/signoz --versions | head
helm search repo signoz/k8s-infra --versions | head
```

## Related ADR

- [ADR 0001 — SigNoz as observability backend](../adr/0001-signoz-as-observability-backend.md)
