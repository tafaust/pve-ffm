# Renovate

[Renovate](https://docs.renovatebot.com/) bumps Helm chart versions, Docker tags, and GitHub Actions. This repo includes a minimal [`renovate.json`](../renovate.json) at the root.

**Operational notes**

- Pin Argo `targetRevision` fields explicitly; Renovate will open PRs when upstream charts move.
- Review Cilium / cert-manager major bumps in a staging cluster first.
- Keep `REPLACE_ME` Git URLs out of Renovate’s dependency graph until you substitute a real `repoURL`.

For GitHub-hosted repos, enable the Renovate GitHub App (or run self-hosted). No CI is wired in this scaffold.
