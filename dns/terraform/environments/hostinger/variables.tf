variable "hostinger_api_token" {
  type        = string
  sensitive   = true
  description = "Hostinger API token (TF_VAR_hostinger_api_token)."
}

variable "zone" {
  type        = string
  description = "Zone apex string in Hostinger DNS (must exist)."
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
