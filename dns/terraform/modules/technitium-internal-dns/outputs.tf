output "zone_name" {
  value       = var.zone_name
  description = "Zone Technitium uses for records."
}

output "record_ids" {
  value       = { for k, r in technitium_record.this : k => r.id }
  description = "Composite record ids from provider."
}
