variable "hetzner_dns_api_token" {
  type        = string
  sensitive   = true
  description = "Hetzner DNS API token (TF_VAR_hetzner_dns_api_token)."
}

variable "zone_name" {
  type = string
}

variable "create_mailcow_records" {
  type        = bool
  default     = false
  description = "When true, create Mailcow-oriented RRs (needs mail_hostname + ipv4 + optional DKIM map)."
}

variable "mail_hostname" {
  type        = string
  default     = ""
  description = "FQDN e.g. mail.example.com"
}

variable "mail_server_ipv4" {
  type    = string
  default = ""
}

variable "dkim_txt_by_name" {
  type    = map(string)
  default = {}
}

variable "dmarc_txt" {
  type    = string
  default = ""
}
