# ADR 0002 — Do not use Bitnami charts or images

## Status

Accepted

## Context

Bitnami’s Helm catalog and image publishing model have shifted over time; many teams now treat Bitnami as a **supply-chain and deprecation risk** compared with vendor-first charts or upstream-maintained containers.

## Decision

- Do **not** deploy Bitnami Helm charts or Bitnami-built container images from this scaffold.
- Prefer **vendor-maintained** charts (for example Jetstack cert-manager, ingress-nginx, StackGres) or **first-party** images.
- For Keycloak, use **codecentric/keycloakx** (Helm) or the **official Keycloak** distribution — not `bitnami/keycloak`.

## Consequences

- Slightly more assembly work for some apps (values, databases, operators).
- Clearer upgrade ownership and fewer “black box” image layers from a third-party republisher.

## Links

- [ADR 0003](0003-kustomize-for-env-specific-config.md) (configuration layering)
