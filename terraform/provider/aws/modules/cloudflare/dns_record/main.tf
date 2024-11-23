resource "cloudflare_record" "this" {
  zone_id = var.zone_id
  name    = var.name
  content   = var.value
  type    = var.type
  ttl     = var.ttl
}