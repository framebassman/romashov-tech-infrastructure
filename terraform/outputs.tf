output "oci_vm_public_ip" {
  description = "Public IP для SSH на sweden-node"
  value       = module.oci.instance_public_ip
}

output "vpn_metrics_allowed_source_ip" {
  description = "Public IP sweden-node (Alloy)."
  value       = module.oci.instance_public_ip
}

output "public_status_page_url" {
  description = "Public URL of the VPN status page in Grafana Cloud (replaces monitoring.romashov.tech/status/vpn)."
  value       = module.grafana_monitoring.public_status_page_url
}

output "d1_romashov_tech_database_id" {
  description = "UUID новой D1 базы romashov-tech — подставить в wrangler.toml после копирования данных"
  value       = module.cloudflare.d1_romashov_tech_database_id
}
