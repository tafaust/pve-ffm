# ADR 0001: SigNoz as the homelab observability backend

## Status

Accepted

## Context

The cluster runs mixed platform and user workloads on **k3s** (see root [README.md](../../README.md)). We need **traces, metrics, and logs** in one place, with a path for **Kubernetes “cluster itself”** telemetry (nodes, kubelet, API-derived metadata) and for **application OTLP** export, without introducing **Bitnami** Helm charts into this slice of the stack.

Requirements:

- GitOps via **Argo CD** app-of-apps and in-repo **Helm values** layering (`base/` + `overlays/<env>/`).
- Prefer the **official SigNoz Kubernetes / Helm** install path documented at [Kubernetes install](https://signoz.io/docs/install/kubernetes/) (Helm repo `https://charts.signoz.io`, chart **`signoz`**, pinned `targetRevision` in the Application manifest).
- Homelab-appropriate defaults (single-node / low replica) with a documented path to HA sizing later.

## Decision

Adopt **self-hosted SigNoz** using the upstream **`signoz/signoz`** Helm chart (ClickHouse + OpenTelemetry Collector + query/frontend components as defined by that chart), in namespace **`observability`**, with:

- **Cluster telemetry** via the official companion chart **`signoz/k8s-infra`** ([k8s-infra docs](https://signoz.io/docs/opentelemetry-collection-agents/k8s/k8s-infra/)), sending OTLP to the in-cluster collector Service created by the main release (`signoz-otel-collector` in this layout).
- **Optional OpenTelemetry Operator** as a separate Argo `Application` ([Helm operator chart](https://opentelemetry.io/docs/platforms/kubernetes/helm/operator/)) for teams that want **Instrumentation** / **OpenTelemetryCollector** CRDs; auto-instrumentation capabilities vary by language and are **not assumed** here.

Values live under `clusters/prod/manifests/signoz/` with **base + prod overlay** YAML merged by Argo CD (`spec.sources` Helm `valueFiles` pattern).

## Consequences

### Positive

- One backend for **logs, metrics, and traces** with OTLP as the primary app integration.
- **k8s-infra** presets cover kubelet-oriented workload metrics, host metrics, cluster-level signals, and pod log collection without hand-rolling the same receivers.
- Charts and images are **SigNoz / ClickHouse / OpenTelemetry / Altinity**-centric; we do **not** add Bitnami charts for this observability stack (the upstream SigNoz ClickHouse values still **reference** Bitnami chart docs for ZooKeeper field semantics; the chart defaults to **`signoz/zookeeper`** images, not a Bitnami chart dependency).

### Negative / risks

- **ClickHouse + ZooKeeper + collectors** are resource-heavy compared to a metrics-only stack; homelab nodes need headroom (PVC growth, compaction, spikes during query).
- **Backups** of telemetry data are operator responsibility (PVC snapshots, object storage cold tier, or externalized ClickHouse); default chart passwords must be **rotated** for anything beyond disposable labs (see [docs/runbooks/signoz.md](../runbooks/signoz.md)).
- **Retention** is driven by disk, ClickHouse TTL policies, and SigNoz product settings over time; tuning requires reading current SigNoz release docs rather than a single static value.
- **Argo CD 2.6+** is required for `spec.sources` Helm value files from Git alongside a Helm repository chart.

## Alternatives considered (brief)

| Option | Why not chosen |
|--------|----------------|
| **Grafana LGTM stack** (Mimir/Loki/Tempo + Grafana) | Strong multi-signal story, but higher moving parts and different ingestion ergonomics for a small homelab; SigNoz bundles the “APM UI + backend” coherently for OTLP-first teams. |
| **Grafana Cloud** / **Datadog** / other SaaS | Offloads ops; recurring cost and data egress/privacy trade-offs for a lab cluster. |
| **VictoriaMetrics + Grafana + separate tracing** | Very capable metrics; tracing/logs still additional systems and glue. |
| **Prometheus only** | Excellent for metrics; does not cover traces/logs natively at the same depth without add-ons. |

## References

- SigNoz Kubernetes install: https://signoz.io/docs/install/kubernetes/
- SigNoz Argo CD notes: https://signoz.io/docs/install/argocd
- k8s-infra agent: https://signoz.io/docs/opentelemetry-collection-agents/k8s/k8s-infra/
- OpenTelemetry Operator Helm: https://opentelemetry.io/docs/platforms/kubernetes/helm/operator/
