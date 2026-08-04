terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}

variable "zone_id" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "mail_hostname" {
  type = string
}

variable "mail_server_ipv4" {
  type = string
}

variable "record_ttl" {
  type    = number
  default = 3600
}

variable "dkim_txt_by_name" {
  type    = map(string)
  default = {}
}

variable "dmarc_txt" {
  type    = string
  default = ""
}

locals {
  mail_rel = replace(var.mail_hostname, ".${var.zone_name}", "")
}

resource "ionoscloud_dns_record" "mail_a" {
  zone_id = var.zone_id
  name    = local.mail_rel
  type    = "A"
  content = var.mail_server_ipv4
  ttl     = var.record_ttl
}

resource "ionoscloud_dns_record" "mx" {
  zone_id  = var.zone_id
  name     = "@"
  type     = "MX"
  content  = var.mail_hostname
  ttl      = var.record_ttl
  priority = 10
}

resource "ionoscloud_dns_record" "spf" {
  zone_id = var.zone_id
  name    = "@"
  type    = "TXT"
  content = "v=spf1 mx a:${var.mail_hostname} ~all"
  ttl     = var.record_ttl
}

resource "ionoscloud_dns_record" "dkim" {
  for_each = var.dkim_txt_by_name
  zone_id  = var.zone_id
  name     = each.key
  type     = "TXT"
  content  = each.value
  ttl      = var.record_ttl
}

resource "ionoscloud_dns_record" "dmarc" {
  count   = var.dmarc_txt != "" ? 1 : 0
  zone_id = var.zone_id
  name    = "_dmarc"
  type    = "TXT"
  content = var.dmarc_txt
  ttl     = var.record_ttl
}

resource "ionoscloud_dns_record" "autoconfig" {
  zone_id = var.zone_id
  name    = "autoconfig"
  type    = "CNAME"
  content = var.mail_hostname
  ttl     = var.record_ttl
}

resource "ionoscloud_dns_record" "autodiscover" {
  zone_id = var.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  content = var.mail_hostname
  ttl     = var.record_ttl
}
