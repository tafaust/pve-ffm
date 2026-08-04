terraform {
  required_version = ">= 1.3.0"
  required_providers {
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "~> 2.1"
    }
  }
}

variable "zone_id" {
  type        = string
  description = "Existing Hetzner DNS zone id (from hetzner-dns-zone module output)."
}

variable "zone_name" {
  type        = string
  description = "Zone apex (e.g. example.com) — used to derive relative hostnames."
}

variable "mail_hostname" {
  type        = string
  description = "MAIL_HOSTNAME FQDN (e.g. mail.example.com)."
}

variable "mail_server_ipv4" {
  type        = string
  description = "IPv4 of the Mailcow host (A record target)."
}

variable "record_ttl" {
  type        = number
  default     = 300
  description = "TTL for created records."
}

variable "dkim_txt_by_name" {
  type        = map(string)
  description = "TXT RRs for DKIM, keyed by relative record name (e.g. \"dkim._domainkey\" => \"v=DKIM1; ...\")."
  default     = {}
}

variable "dmarc_txt" {
  type        = string
  default     = ""
  description = "Optional DMARC TXT for apex \"_dmarc\" (include leading policy, e.g. v=DMARC1; p=none; rua=mailto:...)."
}

locals {
  mail_rel = replace(var.mail_hostname, ".${var.zone_name}", "")
}

resource "hetznerdns_record" "mail_a" {
  zone_id = var.zone_id
  name    = local.mail_rel
  type    = "A"
  value   = var.mail_server_ipv4
  ttl     = var.record_ttl
}

resource "hetznerdns_record" "mx" {
  zone_id = var.zone_id
  name    = "@"
  type    = "MX"
  value   = "10 ${var.mail_hostname}."
  ttl     = var.record_ttl
}

resource "hetznerdns_record" "spf" {
  zone_id = var.zone_id
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 mx a:${var.mail_hostname} ~all"
  ttl     = var.record_ttl
}

resource "hetznerdns_record" "dkim" {
  for_each = var.dkim_txt_by_name
  zone_id  = var.zone_id
  name     = each.key
  type     = "TXT"
  value    = each.value
  ttl      = var.record_ttl
}

resource "hetznerdns_record" "dmarc" {
  count   = var.dmarc_txt != "" ? 1 : 0
  zone_id = var.zone_id
  name    = "_dmarc"
  type    = "TXT"
  value   = var.dmarc_txt
  ttl     = var.record_ttl
}

resource "hetznerdns_record" "autoconfig" {
  zone_id = var.zone_id
  name    = "autoconfig"
  type    = "CNAME"
  value   = "${var.mail_hostname}."
  ttl     = var.record_ttl
}

resource "hetznerdns_record" "autodiscover" {
  zone_id = var.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  value   = "${var.mail_hostname}."
  ttl     = var.record_ttl
}
