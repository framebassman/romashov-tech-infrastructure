locals {
  zone_id = cloudflare_zone.romashov_tech.id
}

# ── Zone ─────────────────────────────────────────────────────────────────────

resource "cloudflare_zone" "romashov_tech" {
  account_id = var.account_id
  zone       = "romashov.tech"
  plan       = "free"
  # jump_start is a creation-time flag only
  lifecycle { ignore_changes = [jump_start] }
}

# ── DNS — A records ───────────────────────────────────────────────────────────

resource "cloudflare_record" "a_alloy" {
  zone_id = local.zone_id
  name    = "alloy"
  type    = "A"
  content = var.alloy_public_ip
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "a_dash" {
  zone_id = local.zone_id
  name    = "dash"
  type    = "A"
  content = "109.172.90.19"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "a_in_3x" {
  zone_id = local.zone_id
  name    = "in.3x"
  type    = "A"
  content = "109.172.90.19"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_in" {
  zone_id = local.zone_id
  name    = "in"
  type    = "A"
  content = "109.172.90.19"
  proxied = false
  ttl     = 900
}

# status.romashov.tech — Cloudflare Pages wrapper (romashov-tech/services/status).
# Grafana paths (/public-dashboards/*, /public/*, /api/*) must still reach node2
# via a Configuration Rule / Worker (see services/status/README.md).
resource "cloudflare_record" "cname_status" {
  zone_id = local.zone_id
  name    = "status"
  type    = "CNAME"
  content = "romashov-tech-status.pages.dev"
  proxied = true
  ttl     = 1
}

resource "cloudflare_record" "a_node1" {
  zone_id = local.zone_id
  name    = "node1"
  type    = "A"
  content = "91.84.124.164"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_node2" {
  zone_id = local.zone_id
  name    = "node2"
  type    = "A"
  content = "109.172.90.19"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_node3" {
  zone_id = local.zone_id
  name    = "node3"
  type    = "A"
  content = "91.84.124.164"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_node4" {
  zone_id = local.zone_id
  name    = "node4"
  type    = "A"
  content = "91.84.124.164"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_out_3x" {
  zone_id = local.zone_id
  name    = "out.3x"
  type    = "A"
  content = "185.121.233.152"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_out" {
  zone_id = local.zone_id
  name    = "out"
  type    = "A"
  content = "109.172.90.19"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "a_russia" {
  zone_id = local.zone_id
  name    = "russia"
  type    = "A"
  content = "109.172.90.19"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "a_tg" {
  zone_id = local.zone_id
  name    = "tg"
  type    = "A"
  content = "91.84.124.164"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_v2_tg" {
  zone_id = local.zone_id
  name    = "v2.tg"
  type    = "A"
  content = "91.84.124.164"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_v3_tg" {
  zone_id = local.zone_id
  name    = "v3.tg"
  type    = "A"
  content = "144.124.231.157"
  proxied = false
  ttl     = 900
}

resource "cloudflare_record" "a_vault" {
  zone_id = local.zone_id
  name    = "vault"
  type    = "A"
  content = "109.172.90.19"
  proxied = true
  ttl     = 1
}

# Zone-wide SSL mode. Originally added by the (now-closed) DNS-flip-to-sweden
# PR which moved vault.romashov.tech to sweden1 over HTTP. That migration is
# paused (A1.Flex capacity in Stockholm AD-1 is exhausted), but the override
# resource was created in state by that PR's CI apply. Declaring it here
# keeps state and code consistent so terraform doesn't try to destroy it —
# Cloudflare's Free plan rejects writes to some read-only settings on destroy,
# which made the destroy path unrecoverable. Flexible SSL is fine for the
# current zone setup: a_vault is the only externally-hosted proxied record,
# and Traefik on node2 has http-point with auto-redirect to https-point, so
# CF→node2 over HTTP works.
resource "cloudflare_zone_settings_override" "romashov_tech" {
  zone_id = local.zone_id
  settings {
    ssl = "flexible"
  }
}

resource "cloudflare_record" "a_vpn" {
  zone_id = local.zone_id
  name    = "vpn"
  type    = "A"
  content = "91.84.124.164"
  proxied = false
  ttl     = 300
}

# dummy IP — redirected to Pages via proxied CNAME at apex
resource "cloudflare_record" "a_www" {
  zone_id = local.zone_id
  name    = "www"
  type    = "A"
  content = "192.0.2.1"
  proxied = true
  ttl     = 1
}

# AAAA 100:: dummy records for api.foodikal and white-list-check-api are managed
# by Cloudflare Workers routing — read-only via DNS API (error 1043), not managed here.

# ── DNS — CNAME records ───────────────────────────────────────────────────────

resource "cloudflare_record" "cname_apex" {
  zone_id = local.zone_id
  name    = "romashov.tech"
  type    = "CNAME"
  content = "romashov-tech-web.pages.dev"
  proxied = true
  ttl     = 1
}

# img.cartok CNAME → public.r2.dev is auto-generated by R2, read-only via DNS API (error 1052).

resource "cloudflare_record" "cname_webhook" {
  zone_id = local.zone_id
  name    = "webhook"
  type    = "CNAME"
  content = "66ff916b-882e-431a-80dc-f89db5e3e3b0.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

# ── DNS — MX records ──────────────────────────────────────────────────────────

resource "cloudflare_record" "mx_apex" {
  zone_id  = local.zone_id
  name     = "romashov.tech"
  type     = "MX"
  content  = "mx.yandex.net"
  priority = 10
  proxied  = false
  ttl      = 1
}

# ── DNS — TXT records ─────────────────────────────────────────────────────────

resource "cloudflare_record" "txt_acme_challenge_m_inventory" {
  zone_id = local.zone_id
  name    = "_acme-challenge.m.inventory"
  type    = "TXT"
  content = "gr5QNpe1jg2tKcukt95dNC-uptmtSeiXzuwpWH5fEJw"
  proxied = false
  ttl     = 120
}

resource "cloudflare_record" "txt_mail_dkim" {
  zone_id = local.zone_id
  name    = "mail._domainkey"
  type    = "TXT"
  content = "v=DKIM1; k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbSNNEHtWeRj/cs5JPgi2QmPu9mHDeQwOVANihaITDjCq8Q4JNtPhoMzUxllY5wTYO776BFRU7+gEfXu0kM3GUamPmQetcA/xQCmWoCHhxjEltifCPDavDKS+bZNuuL6brDaXAV4xl1SB4qjbCAt5YmIl3V8rBcwjUhr+c8awctQIDAQAB"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "txt_apex_spf" {
  zone_id = local.zone_id
  name    = "romashov.tech"
  type    = "TXT"
  content = "v=spf1 redirect=_spf.yandex.net"
  proxied = false
  ttl     = 1
}

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

# ── Pages ─────────────────────────────────────────────────────────────────────

resource "cloudflare_pages_project" "romashov_tech_web" {
  account_id        = var.account_id
  name              = "romashov-tech-web"
  production_branch = "master"

  # GitHub integration, env vars, and build config are managed outside TF
  lifecycle { ignore_changes = [source, build_config, deployment_configs] }
}

resource "cloudflare_pages_project" "romashov_tech_status" {
  account_id        = var.account_id
  name              = "romashov-tech-status"
  production_branch = "master"

  lifecycle { ignore_changes = [source, build_config, deployment_configs] }
}

# Custom domain for status Pages (DNS: cloudflare_record.cname_status above).
# pages_domain does not create the CNAME — both resources are required.
resource "cloudflare_pages_domain" "status_romashov_tech" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.romashov_tech_status.name
  domain       = "status.romashov.tech"

  depends_on = [cloudflare_record.cname_status]
}
