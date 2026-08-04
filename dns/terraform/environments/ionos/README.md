# IONOS DNS root

Token: `export TF_VAR_ionos_token=...` or `IONOS_TOKEN` per provider docs.

```bash
terraform -chdir=dns/terraform/environments/ionos init
terraform -chdir=dns/terraform/environments/ionos plan
```
