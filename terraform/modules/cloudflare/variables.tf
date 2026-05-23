variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "status_redirect_url" {
  description = "Full URL the status.romashov.tech page rule redirects to (Grafana Cloud public dashboard). Comes from grafana-monitoring module output."
  type        = string
}
