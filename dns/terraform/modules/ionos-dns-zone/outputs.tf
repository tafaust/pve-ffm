output "zone_id" {
  value       = ionoscloud_dns_zone.this.id
  description = "IONOS DNS zone id for ionoscloud_dns_record.zone_id"
}

output "zone_name" {
  value       = ionoscloud_dns_zone.this.name
  description = "Zone apex."
}
