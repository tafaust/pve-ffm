# Mailcow DNS records — IONOS Cloud DNS

Uses `ionoscloud_dns_record`. MX uses `priority` + `content` hostname per IONOS provider schema (verify in `terraform plan` — adjust if API expects FQDN with trailing dot).

Token auth only: `IONOS_TOKEN` or provider `token`.
