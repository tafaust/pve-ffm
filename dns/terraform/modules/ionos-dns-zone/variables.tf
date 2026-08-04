variable "zone_name" {
  type        = string
  description = "Zone apex FQDN (e.g. example.com)."
}

variable "description" {
  type        = string
  default     = "managed by terraform"
  description = "IONOS DNS zone description."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether the zone is active."
}
