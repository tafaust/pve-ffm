module "zone" {
  source    = "../../modules/hetzner-dns-zone"
  zone_name = var.zone_name
}

module "mailcow" {
  count            = var.create_mailcow_records ? 1 : 0
  source           = "../../modules/mailcow-dns-hetzner"
  zone_id          = module.zone.zone_id
  zone_name        = var.zone_name
  mail_hostname    = var.mail_hostname
  mail_server_ipv4 = var.mail_server_ipv4
  dkim_txt_by_name = var.dkim_txt_by_name
  dmarc_txt        = var.dmarc_txt
}

output "zone_id" {
  value = module.zone.zone_id
}

output "name_servers_hint" {
  value = module.zone.name_servers_hint
}
