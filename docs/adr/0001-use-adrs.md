# ADR 0001 — Use architecture decision records

## Status

Accepted

## Context

This repository mixes GitOps, Ansible, DNS, and identity concerns. Contributors need a lightweight, versioned trail of **why** constraints exist (not only **what** changed in YAML).

## Decision

Use Markdown ADRs under `docs/adr/`, numbered sequentially, with the shared template in `0000-adr-template.md`.

## Consequences

- Trade-offs and non-goals stay discoverable in Git history.
- New constraints (for example “no Bitnami”) get a durable rationale instead of scattered comments.

## Links

- [Michael Nygard’s ADR article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
