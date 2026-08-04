# Client / tenant template (repository-wide)

Forks can use this folder as a checklist for **non-secret** parameters that repeat across Ansible, Argo CD, and Terraform.

- Copy to `clients/<name>/` and customize the example files.
- Keep real tokens and passwords in Vault, SOPS, or your CI secret store — not in Git.

See also: [dns/clients/_template/](../dns/clients/_template/) for DNS-specific `terraform.tfvars` examples.
