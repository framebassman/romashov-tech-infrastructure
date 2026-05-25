# Public status page replacing Uptime Kuma's status/vpn. Dashboard JSON is a
# template so we can inject the actual Prometheus datasource UID at render time.
resource "grafana_dashboard" "vpn_status" {
  config_json = templatefile("${path.module}/dashboards/vpn-status.json.tftpl", {
    prometheus_uid  = data.grafana_data_source.prometheus.uid
    link_gbps       = var.vless_link_gbps
    link_bits_per_s = var.vless_link_gbps * 1e9
  })
  folder    = grafana_folder.synthetic_monitoring.uid
  overwrite = true
}

# Public read-only link. anyone with the URL can view (no Grafana auth).
resource "grafana_dashboard_public" "vpn_status" {
  dashboard_uid = grafana_dashboard.vpn_status.uid
  is_enabled    = true

  # Time selection picker on a public dashboard is usually noise for a
  # status page; the dashboard auto-refreshes every 5 min and is meant to
  # show "now" status.
  time_selection_enabled = false

  # Annotations are admin-only context; don't leak them.
  annotations_enabled = false
}
