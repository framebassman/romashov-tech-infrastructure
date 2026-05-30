output "zone_id" {
  description = "Zone ID for romashov.tech"
  value       = cloudflare_zone.romashov_tech.id
}

output "slack_grafana_bot_token" {
  description = "Slack Bot OAuth token read from Workers KV (romashov-tech/slack_grafana_bot_token)"
  value       = data.external.slack_grafana_bot_token.result.value
  sensitive   = true
}
