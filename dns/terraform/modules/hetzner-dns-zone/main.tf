resource "hetznerdns_zone" "this" {
  name = var.zone_name
  ttl  = var.zone_ttl
}
