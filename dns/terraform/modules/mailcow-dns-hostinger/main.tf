terraform {
  required_version = ">= 1.3.0"
  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 0.1"
    }
  }
}

variable "zone" {
  type        = string
  description = "DNS zone apex as shown in Hostinger (e.g. example.com). Zone must already exist in hPanel."
}

variable "mail_hostname" {
  type        = string
  description = "MAIL_HOSTNAME FQDN (e.g. mail.example.com)."
}

variable "mail_server_ipv4" {
  type        = string
  description = "IPv4 of the Mailcow host."
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
  mail_rel = replace(var.mail_hostname, ".${var.zone}", "")
}

resource "hostinger_dns_record" "mail_a" {
  zone  = var.zone
  name  = local.mail_rel
  type  = "A"
  value = var.mail_server_ipv4
  ttl   = var.record_ttl
}

resource "hostinger_dns_record" "mx" {
  zone  = var.zone
  name  = "@"
  type  = "MX"
  value = "10 ${var.mail_hostname}"
  ttl   = var.record_ttl
}

resource "hostinger_dns_record" "spf" {
  zone  = var.zone
  name  = "@"
  type  = "TXT"
  value = "v=spf1 mx a:${var.mail_hostname} ~all"
  ttl   = var.record_ttl
}

resource "hostinger_dns_record" "dkim" {
  for_each = var.dkim_txt_by_name
  zone     = var.zone
  name     = each.key
  type     = "TXT"
  value    = each.value
  ttl      = var.record_ttl
}

resource "hostinger_dns_record" "dmarc" {
  count = var.dmarc_txt != "" ? 1 : 0
  zone  = var.zone
  name  = "_dmarc"
  type  = "TXT"
  value = var.dmarc_txt
  ttl   = var.record_ttl
}

resource "hostinger_dns_record" "autoconfig" {
  zone  = var.zone
  name  = "autoconfig"
  type  = "CNAME"
  value = var.mail_hostname
  ttl   = var.record_ttl
}

resource "hostinger_dns_record" "autodiscover" {
  zone  = var.zone
  name  = "autodiscover"
  type  = "CNAME"
  value = var.mail_hostname
  ttl   = var.record_ttl
}
