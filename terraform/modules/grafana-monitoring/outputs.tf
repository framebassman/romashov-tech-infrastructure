output "check_ids" {
  description = "Map of SM check job name → check id"
  value = merge(
    { for k, c in grafana_synthetic_monitoring_check.tcp : k => c.id },
    { for k, c in grafana_synthetic_monitoring_check.https : k => c.id },
  )
}

output "slack_contact_point_name" {
  description = "Name of the Slack contact point — useful if you wire up other policies elsewhere."
  value       = grafana_contact_point.slack.name
}

output "public_status_page_url" {
  description = "Public URL of the VPN status page (replaces Uptime Kuma's /status/vpn). Anyone with the link can view."
  value       = "https://${var.stack_slug}.grafana.net/public-dashboards/${grafana_dashboard_public.vpn_status.access_token}"
}
