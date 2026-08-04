# Contributing from a fork

This scaffold is meant to be copied and **parameterized** for other orgs, tenants, or OSS consumers. Keep secrets out of Git.

## Replace placeholders

- **`YOUR_ORG` / `REPLACE_ME`**: Git remote in Argo CD manifests (`repoURL`) and any `https://github.com/REPLACE_ME/pve-ffm.git` strings under `clusters/prod/`.
- **`targetRevision`**: Pin to a tag or release branch after you validate upgrades.
- **DNS**: Pick **one** provider root `dns/terraform/environments/{hetzner,ionos,hostinger}/`, add `backend.tf`, maintain `dns/clients/<name>/terraform.tfvars.example` (non-secret only).
- **Terraform workspace / backend**: Each environment directory should use its own state key (see `dns/terraform/environments/*/backend.tf.example`).

## Argo CD

1. Install Argo CD in `argocd`.
2. `kubectl apply -n argocd -f clusters/prod/argocd/project-default.yaml`
3. `kubectl apply -n argocd -f clusters/prod/argocd/root-app.yaml` after fixing `repoURL` / `targetRevision`.

Tighten `AppProject` `sourceRepos` and `destinations` before production.

## Conventions

- **No Bitnami** charts/images (see [ADR 0002](adr/0002-no-bitnami.md)).
- **Kustomize overlays** for env-specific Kubernetes config ([ADR 0003](adr/0003-kustomize-for-env-specific-config.md)).

## ADRs

Record meaningful fork-level decisions under `docs/adr/` using `0000-adr-template.md`.
