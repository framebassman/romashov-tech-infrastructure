variable "stack_slug" {
  description = "Grafana Cloud stack slug — used to build the stack URL <slug>.grafana.net"
  type        = string
}

variable "slack_bot_token" {
  description = "Slack Bot User OAuth Token (xoxb-...) used by the Grafana Slack contact point"
  type        = string
  sensitive   = true
}

variable "slack_channel" {
  description = "Slack channel (without #) the bot will post alerts to. Bot must be invited unless chat:write.public is granted."
  type        = string
}

variable "probes" {
  description = "Public probe names to schedule each check from. Stockholm = closest publicly-available probe to RU (no public probes exist inside Russia). Frankfurt = central-EU baseline. 8 checks × 2 probes × 10min ≈ 69k execs/month, fits the 100k free-tier quota with ~31k headroom (room for ~3 more checks at the same freq)."
  type        = list(string)
  default     = ["Stockholm", "Frankfurt"]
}

variable "check_frequency_seconds" {
  description = "How often each check runs, in seconds. 600s (10 min) sized to leave quota headroom for adding more checks later — see comment on `probes`. Detection latency: probe miss + 11m for-clause + next probe ≈ 11-21 min."
  type        = number
  default     = 600
}

variable "tcp_targets" {
  description = "TCP-port checks migrated from Uptime Kuma. Key becomes the SM job name."
  type = map(object({
    target = string
    labels = map(string)
  }))
  default = {
    node1 = {
      target = "node1.romashov.tech:4443"
      labels = { service = "openconnect", instance = "node1" }
    }
    node2 = {
      target = "node2.romashov.tech:4443"
      labels = { service = "openconnect", instance = "node2" }
    }
    node3 = {
      target = "node3.romashov.tech:4443"
      labels = { service = "openconnect", instance = "node3" }
    }
    node4 = {
      target = "node4.romashov.tech:4443"
      labels = { service = "openconnect", instance = "node4" }
    }
    "3x-ui-in" = {
      target = "in.3x.romashov.tech:443"
      labels = { service = "3x-ui-reality", direction = "in" }
    }
    "3x-ui-out" = {
      target = "out.3x.romashov.tech:443"
      labels = { service = "3x-ui-reality", direction = "out" }
    }
    mtproxy = {
      target = "tg.romashov.tech:443"
      labels = { service = "telegram-mtproxy" }
    }
  }
}

variable "https_targets" {
  description = "HTTPS checks migrated from Uptime Kuma. dash is behind basic auth, so 401 is treated as 'reachable'."
  type = map(object({
    target              = string
    valid_status_codes  = list(number)
    labels              = map(string)
    cert_expiry_warning = bool
  }))
  default = {
    dash = {
      target             = "https://dash.romashov.tech"
      valid_status_codes = [200, 401]
      labels             = { service = "traefik-dashboard" }
      # Kuma's "Certificate" monitor existed specifically to alert on cert
      # expiry — preserve that intent.
      cert_expiry_warning = true
    }
  }
}

variable "cert_expiry_warning_days" {
  description = "Fire a warning when probe_ssl_earliest_cert_expiry is closer than N days. Le certs are 90-day, so 14 days = ~16% remaining."
  type        = number
  default     = 14
}

variable "vless_link_gbps" {
  description = "Nominal VPS link speed (Gbit/s) for VLESS channel utilization gauges on the public status dashboard."
  type        = number
  default     = 10
}
