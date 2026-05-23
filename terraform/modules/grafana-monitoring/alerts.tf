# ── Datasource lookup ──────────────────────────────────────────────────────
# Grafana Cloud auto-provisions a Prometheus datasource with the stack slug
# embedded ("grafanacloud-<slug>-prom"). Look it up to get the real UID.
data "grafana_data_source" "prometheus" {
  name = "grafanacloud-${var.stack_slug}-prom"
}

# ── Slack contact point ────────────────────────────────────────────────────
resource "grafana_contact_point" "slack" {
  name = "slack-${var.slack_channel}"

  slack {
    token     = var.slack_bot_token
    recipient = var.slack_channel
    title     = "{{ if eq .Status \"firing\" }}🔴{{ else }}✅{{ end }} {{ .CommonLabels.alertname }}"
    text      = <<-EOT
      {{ range .Alerts }}
      *Status:* {{ .Status }}
      *Target:* {{ .Labels.target }}
      *Severity:* {{ .Labels.severity }}
      *Summary:* {{ .Annotations.summary }}
      {{ if .Annotations.runbook_url }}*Runbook:* {{ .Annotations.runbook_url }}{{ end }}
      {{ end }}
    EOT
  }
}

# ── Notification policy ────────────────────────────────────────────────────
# Singleton: configures the root policy for the stack. All synthetic-monitoring
# alerts (matched by label origin=synthetic-monitoring set on each rule) route
# to Slack; everything else falls through to whatever existed before.
resource "grafana_notification_policy" "root" {
  group_by      = ["alertname", "target"]
  contact_point = grafana_contact_point.slack.name

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"

  policy {
    contact_point = grafana_contact_point.slack.name
    matcher {
      label = "origin"
      match = "="
      value = "synthetic-monitoring"
    }
    group_by        = ["alertname", "target"]
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "4h"
  }
}

# ── Folder ─────────────────────────────────────────────────────────────────
resource "grafana_folder" "synthetic_monitoring" {
  title = "Synthetic Monitoring Alerts"
}

# ── TCP probe-failure rules ────────────────────────────────────────────────
resource "grafana_rule_group" "tcp_probe_down" {
  name             = "tcp-probe-down"
  folder_uid       = grafana_folder.synthetic_monitoring.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = var.tcp_targets
    content {
      name           = "TCP probe down: ${rule.key}"
      condition      = "B"
      for            = "11m"
      no_data_state  = "Alerting"
      exec_err_state = "Alerting"

      data {
        ref_id         = "A"
        datasource_uid = data.grafana_data_source.prometheus.uid
        relative_time_range {
          from = 300
          to   = 0
        }
        model = jsonencode({
          editorMode    = "code"
          expr          = "min(probe_success{job=\"${rule.key}\"})"
          intervalMs    = 1000
          legendFormat  = "__auto"
          maxDataPoints = 43200
          range         = true
          refId         = "A"
        })
      }

      data {
        ref_id         = "B"
        datasource_uid = "__expr__"
        relative_time_range {
          from = 0
          to   = 0
        }
        model = jsonencode({
          conditions = [{
            evaluator = { params = [1, 0], type = "lt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }]
          datasource    = { type = "__expr__", uid = "__expr__" }
          expression    = "A"
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "B"
          type          = "classic_conditions"
        })
      }

      labels = merge(rule.value.labels, {
        severity = "critical"
        origin   = "synthetic-monitoring"
        target   = rule.value.target
      })
      annotations = {
        summary = "TCP probe to ${rule.value.target} has failed for 11+ minutes from all configured probes"
      }
    }
  }
}

# ── HTTPS probe-failure rules ──────────────────────────────────────────────
resource "grafana_rule_group" "https_probe_down" {
  name             = "https-probe-down"
  folder_uid       = grafana_folder.synthetic_monitoring.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = var.https_targets
    content {
      name           = "HTTPS probe down: ${rule.key}"
      condition      = "B"
      for            = "11m"
      no_data_state  = "Alerting"
      exec_err_state = "Alerting"

      data {
        ref_id         = "A"
        datasource_uid = data.grafana_data_source.prometheus.uid
        relative_time_range {
          from = 300
          to   = 0
        }
        model = jsonencode({
          editorMode    = "code"
          expr          = "min(probe_success{job=\"${rule.key}\"})"
          intervalMs    = 1000
          legendFormat  = "__auto"
          maxDataPoints = 43200
          range         = true
          refId         = "A"
        })
      }

      data {
        ref_id         = "B"
        datasource_uid = "__expr__"
        relative_time_range {
          from = 0
          to   = 0
        }
        model = jsonencode({
          conditions = [{
            evaluator = { params = [1, 0], type = "lt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }]
          datasource    = { type = "__expr__", uid = "__expr__" }
          expression    = "A"
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "B"
          type          = "classic_conditions"
        })
      }

      labels = merge(rule.value.labels, {
        severity = "critical"
        origin   = "synthetic-monitoring"
        target   = rule.value.target
      })
      annotations = {
        summary = "HTTPS probe to ${rule.value.target} has failed for 11+ minutes from all configured probes"
      }
    }
  }
}

# ── TLS cert-expiry rules ──────────────────────────────────────────────────
# Only for https_targets with cert_expiry_warning=true. Preserves the intent
# of Kuma's "Certificate" monitor type.
resource "grafana_rule_group" "cert_expiring_soon" {
  name             = "cert-expiring-soon"
  folder_uid       = grafana_folder.synthetic_monitoring.uid
  interval_seconds = 3600 # cert state changes slowly; hourly is enough

  dynamic "rule" {
    for_each = { for k, v in var.https_targets : k => v if v.cert_expiry_warning }
    content {
      name           = "TLS cert expiring soon: ${rule.key}"
      condition      = "B"
      for            = "1h"
      no_data_state  = "NoData"
      exec_err_state = "Alerting"

      data {
        ref_id         = "A"
        datasource_uid = data.grafana_data_source.prometheus.uid
        relative_time_range {
          from = 600
          to   = 0
        }
        model = jsonencode({
          editorMode    = "code"
          expr          = "(min(probe_ssl_earliest_cert_expiry{job=\"${rule.key}\"}) - time()) / 86400"
          intervalMs    = 1000
          legendFormat  = "days_remaining"
          maxDataPoints = 43200
          range         = true
          refId         = "A"
        })
      }

      data {
        ref_id         = "B"
        datasource_uid = "__expr__"
        relative_time_range {
          from = 0
          to   = 0
        }
        model = jsonencode({
          conditions = [{
            evaluator = { params = [var.cert_expiry_warning_days, 0], type = "lt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }]
          datasource    = { type = "__expr__", uid = "__expr__" }
          expression    = "A"
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "B"
          type          = "classic_conditions"
        })
      }

      labels = merge(rule.value.labels, {
        severity = "warning"
        origin   = "synthetic-monitoring"
        target   = rule.value.target
      })
      annotations = {
        summary = "TLS cert for ${rule.value.target} expires in fewer than ${var.cert_expiry_warning_days} days"
      }
    }
  }
}
