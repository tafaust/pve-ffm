# Hostinger DNS (records only)

Create zone in hPanel first. Then:

```bash
export TF_VAR_hostinger_api_token="***"
terraform -chdir=dns/terraform/environments/hostinger init
terraform -chdir=dns/terraform/environments/hostinger plan
```

Set `create_mailcow_records=true` + mail vars for Mailcow RR set.
