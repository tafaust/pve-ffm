resource "technitium_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.zone_name
  type  = var.zone_type
}

resource "technitium_record" "this" {
  for_each = var.records

  zone      = var.create_zone ? technitium_zone.this[0].name : var.zone_name
  name      = each.value.name
  type      = each.value.type
  value     = each.value.value
  ttl       = try(each.value.ttl, null)
  priority  = try(each.value.priority, null)
  weight    = try(each.value.weight, null)
  port      = try(each.value.port, null)
  caa_flags = try(each.value.caa_flags, null)
  caa_tag   = try(each.value.caa_tag, null)
  overwrite = try(each.value.overwrite, null)
}
