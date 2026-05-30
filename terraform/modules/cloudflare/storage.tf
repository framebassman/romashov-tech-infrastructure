# ── R2 Buckets ───────────────────────────────────────────────────────────────

resource "cloudflare_r2_bucket" "backups" {
  account_id = var.account_id
  name       = "backups"
}

resource "cloudflare_r2_bucket" "vpn_certs" {
  account_id = var.account_id
  name       = "vpn-certs"
}

# Terraform remote state backend — do not delete
resource "cloudflare_r2_bucket" "terraform_backend" {
  account_id = var.account_id
  name       = "kolenka-inc-terraform-backend"
}

# ── Workers KV ───────────────────────────────────────────────────────────────

resource "cloudflare_workers_kv_namespace" "romashov_tech" {
  account_id = var.account_id
  title      = "romashov-tech"
}

# ── D1 Databases ─────────────────────────────────────────────────────────────

resource "cloudflare_d1_database" "romashov_tech_status_incidents" {
  account_id = var.account_id
  name       = "romashov-tech-status-incidents"
  read_replication = {
    mode = "disabled"
  }
}
