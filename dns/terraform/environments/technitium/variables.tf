variable "technitium_server_url" {
  type        = string
  description = "Technitium REST API base URL (e.g. https://dns.lan:5380). Override with TF_VAR_technitium_server_url or TECHNITIUM_SERVER_URL."
  default     = ""
}

variable "technitium_api_token" {
  type        = string
  sensitive   = true
  description = "API token from Technitium UI (Administration → API Tokens). TF_VAR_technitium_api_token or TECHNITIUM_API_TOKEN."
  default     = ""
}

variable "zone_name" {
  type        = string
  description = "Internal zone (e.g. lab.internal)."
}

variable "create_zone" {
  type        = bool
  default     = true
  description = "Set false if zone already created in UI / import."
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
  description = "Map key = stable id; name = FQDN inside zone."
}
