# NetBird self-hosted

## Components

- **Management** + **Signal** + **Coturn** (see [self-hosted guide](https://docs.netbird.io/selfhosted/selfhosted-guide)).
- **PostgreSQL** for management store at scale (SQLite possible for tiny labs).

## OIDC

Configure NetBird to use **Keycloak** as OIDC provider (same realm you use for apps). LDAP remains mastered in directory; Keycloak federates users.

## Coexistence with WireGuard site-to-site

Keep **FRITZ!Box ↔ DC** WireGuard for routed access to `192.168.20.0/24`. Add NetBird for **mesh / posture / extra peers** without removing the underlay until validated.

## Argo

Add an `Application` when you pick Helm chart or compose translation; chart landscape changes — generate from NetBird release artifacts you pin.
