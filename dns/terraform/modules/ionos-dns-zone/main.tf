resource "ionoscloud_dns_zone" "this" {
  name        = var.zone_name
  description = var.description
  enabled     = var.enabled
}
