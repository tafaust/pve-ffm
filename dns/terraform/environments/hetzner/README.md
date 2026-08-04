# Hetzner DNS environment root

```bash
export TF_VAR_hetzner_dns_api_token="***"
terraform -chdir=dns/terraform/environments/hetzner init
terraform -chdir=dns/terraform/environments/hetzner plan
```

Optional Mailcow: set `create_mailcow_records=true` + `mail_hostname` + `mail_server_ipv4` (+ DKIM map) in `terraform.tfvars`.
