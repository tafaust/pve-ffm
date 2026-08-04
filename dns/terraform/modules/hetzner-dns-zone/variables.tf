variable "zone_name" {
  type        = string
  description = "Authoritative zone name (e.g. example.com)."
}

variable "zone_ttl" {
  type        = number
  description = "Default SOA TTL for the zone object where applicable."
  default     = 86400
}
