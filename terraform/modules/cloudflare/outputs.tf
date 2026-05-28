output "zone_id" {
  description = "Zone ID for romashov.tech"
  value       = cloudflare_zone.romashov_tech.id
}

output "status_incidents_d1_database_id" {
  description = "D1 database ID for status.romashov.tech incident banners"
  value       = cloudflare_d1_database.romashov_tech_status_incidents.id
}
