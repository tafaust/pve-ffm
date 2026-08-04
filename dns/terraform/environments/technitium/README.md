# Technitium (internal DNS)

Terraform manages **zones + records** on [Technitium DNS Server](https://technitium.com/dns/) via provider [`darkhonor/technitium`](https://registry.terraform.io/providers/darkhonor/technitium/latest/docs).

Proxmox VM/LXC for Technitium stays **manual** (same as rest of repo); after install, create API token in UI (**Administration → API Tokens**), then point Terraform at `server_url` + token.

## Credentials

Prefer env (provider also reads these when HCL vars empty):

```bash
export TECHNITIUM_SERVER_URL="https://dns.example:5380"
export TECHNITIUM_API_TOKEN="***"
```

Or:

```bash
export TF_VAR_technitium_server_url="https://dns.example:5380"
export TF_VAR_technitium_api_token="***"
```

## Usage

From this directory:

```bash
cp backend.tf.example backend.tf   # or remote backend
terraform init
terraform plan
terraform apply
```

`zone_name` + optional `records` live in `terraform.tfvars` (gitignored pattern) or CI vars. Example fragment: [../../../clients/example-technitium/terraform.tfvars.example](../../../clients/example-technitium/terraform.tfvars.example).

## TLS

Internal CA: set provider TLS options per [provider docs](https://registry.terraform.io/providers/darkhonor/technitium/latest/docs) (`ca_cert_file`, `TECHNITIUM_CACERT`, etc.) if you terminate HTTPS on Technitium with private CA.
