resource "cloudflare_zone" "romashov_tech" {
  account = {
    id = var.account_id
  }
  name = "romashov.tech"
}

# cloudflare_zone_settings_override was removed in v5; each setting is now a
# separate cloudflare_zone_setting resource.
resource "cloudflare_zone_setting" "romashov_tech_ssl" {
  zone_id    = local.zone_id
  setting_id = "ssl"
  value      = "flexible"
}
