variable "ionos_token" {
  type        = string
  sensitive   = true
  description = "IONOS Cloud API token (TF_VAR_ionos_token or IONOS_TOKEN in env)."
}

variable "zone_name" {
  type = string
}

variable "create_mailcow_records" {
  type    = bool
  default = false
}

variable "mail_hostname" {
  type    = string
  default = ""
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
