# grafana-monitoring

Active uptime probing + alert delivery to Slack, replacing the old self-hosted
Uptime Kuma instance on node1.

## What it manages

- **Synthetic Monitoring checks** scheduled from Stockholm + Frankfurt public
  probes at 7-minute intervals (sized to fit Grafana Cloud free-tier
  100k execs/month; 7 × 2 × (60/420) × 60 × 24 × 30 ≈ 86k/month, ~14k headroom).
  Stockholm chosen as the closest publicly-available probe to RU — there are no
  Grafana Cloud probes inside Russia.
  - 4 × TCP checks on openconnect VPN ports (`node{1..4}.romashov.tech:4443`)
  - 2 × TCP checks on Reality endpoints (`{in,out}.3x.romashov.tech:443`)
  - **Public status dashboard** (`vpn-status`) — uptime + VLESS channel utilization
    gauges (70/90% thresholds, default 10 Gbit/s link via `vless_link_gbps`)
  - 1 × HTTPS check on `dash.romashov.tech` (basic-auth-fronted; 200 + 401
    treated as reachable, since the TLS handshake itself is the signal)
- **Slack contact point** using a Bot User OAuth Token (`xoxb-…`).
- **Notification policy** routing everything labelled `origin=synthetic-monitoring`
  to Slack, grouped by `alertname` + `target`.
- **Alert rules** (one per check):
  - `TCP/HTTPS probe down` — fires when `probe_success == 0` for 2 min from
    all probes.
  - `TLS cert expiring soon` — for HTTPS targets with `cert_expiry_warning=true`,
    fires when fewer than `cert_expiry_warning_days` (default 14) remain.

## Inputs

Set in the root `terraform.tfvars` / via KV-derived env (`TF_VAR_…`):

| Variable | Comes from |
|---|---|
| `grafana_cloud_api_key` | KV `grafana_cloud_api_key` — used as the `grafana` provider `auth` |
| `grafana_synthetic_monitoring_token` | KV `GRAFANA_SYNTHETIC_MONITORING_TOKEN` — `sm_access_token` |
| `slack_grafana_bot_token` | KV `slack_grafana_bot_token` — Slack app's `xoxb-…` |
| `slack_grafana_alert_channel` | KV `slack_grafana_alert_channel` — channel name without `#` |

## Adding a target

Append to `tcp_targets` or `https_targets` in `variables.tf`. The check, alert
rule, and Slack routing are generated from `for_each`, so no copy-paste.

## Decommissioning Uptime Kuma

Replaced by the public Grafana Cloud dashboard. The Kuma container on node1
and the Aiven MySQL service `kolenka-inc-mysql` (which backed it) have both
been removed.
