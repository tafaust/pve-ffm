module "internal_dns" {
  source = "../../modules/technitium-internal-dns"

  zone_name   = var.zone_name
  create_zone = var.create_zone
  zone_type   = var.zone_type
  records     = var.records
}

output "zone_name" {
  value = module.internal_dns.zone_name
}

output "record_ids" {
  value = module.internal_dns.record_ids
}
