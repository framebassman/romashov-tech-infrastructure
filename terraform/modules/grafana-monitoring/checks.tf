# Public probes published by Grafana Synthetic Monitoring. Names are
# case-sensitive ("Frankfurt", not "frankfurt"). Lookup map by name → id.
data "grafana_synthetic_monitoring_probes" "all" {}

locals {
  probe_ids = [for name in var.probes : data.grafana_synthetic_monitoring_probes.all.probes[name]]
}

resource "grafana_synthetic_monitoring_check" "tcp" {
  for_each = var.tcp_targets

  job     = each.key
  target  = each.value.target
  enabled = true
  probes  = local.probe_ids
  labels  = each.value.labels

  frequency = var.check_frequency_seconds * 1000 # ms
  timeout   = 10000

  settings {
    tcp {
      ip_version = "Any"
    }
  }
}

resource "grafana_synthetic_monitoring_check" "https" {
  for_each = var.https_targets

  job     = each.key
  target  = each.value.target
  enabled = true
  probes  = local.probe_ids
  labels  = each.value.labels

  frequency = var.check_frequency_seconds * 1000
  timeout   = 10000

  settings {
    http {
      ip_version          = "Any"
      method              = "GET"
      no_follow_redirects = false
      valid_status_codes  = each.value.valid_status_codes

      tls_config {
        insecure_skip_verify = false
      }
    }
  }
}
