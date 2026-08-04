# Hostinger has no zone resource in provider — only records. No module.zone here.
module "mailcow" {
  count            = var.create_mailcow_records ? 1 : 0
  source           = "../../modules/mailcow-dns-hostinger"
  zone             = var.zone
  mail_hostname    = var.mail_hostname
  mail_server_ipv4 = var.mail_server_ipv4
  dkim_txt_by_name = var.dkim_txt_by_name
  dmarc_txt        = var.dmarc_txt
}
