variable "zone_name" {
  type        = string
  description = "Authoritative zone name (e.g. lab.internal)."
}

variable "create_zone" {
  type        = bool
  default     = true
  description = "If false, zone must already exist on server; only records managed."
}

variable "zone_type" {
  type        = string
  default     = "Primary"
  description = "Technitium zone type when create_zone is true."
}

variable "records" {
  type = map(object({
    name      = string
    type      = string
    value     = string
    ttl       = optional(number)
    priority  = optional(number)
    weight    = optional(number)
    port      = optional(number)
    caa_flags = optional(number)
    caa_tag   = optional(string)
    overwrite = optional(bool)
  }))
  default     = {}
  description = "Map key = stable Terraform id; name = FQDN (see technitium_record docs)."
}
