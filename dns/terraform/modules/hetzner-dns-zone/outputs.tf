output "zone_id" {
  value       = hetznerdns_zone.this.id
  description = "Hetzner DNS zone id for hetznerdns_record.zone_id"
}

output "name_servers_hint" {
  value       = "See Hetzner DNS console for this zone's assigned NS (API zone object does not expose them in provider v2.2)."
  description = "Registrar glue: copy NS from Hetzner UI."
}
