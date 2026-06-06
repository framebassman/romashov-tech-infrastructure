# ── R2 Buckets ───────────────────────────────────────────────────────────────

resource "cloudflare_r2_bucket" "backups" {
  account_id = var.account_id
  name       = "backups"
}

resource "cloudflare_r2_bucket" "vpn_certs" {
  account_id = var.account_id
  name       = "vpn-certs"
}

resource "cloudflare_r2_managed_domain" "vpn_certs" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.vpn_certs.name
  enabled     = true
}

# Writes the computed r2.dev domain to KV so fetch-secrets.sh can render
# services/proxy/config/dynamic/vpn-certs.yml on the host at deploy time.
resource "null_resource" "vpn_certs_r2_domain_to_kv" {
  triggers = {
    domain = cloudflare_r2_managed_domain.vpn_certs.domain
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -sf -X PUT \
        "https://api.cloudflare.com/client/v4/accounts/${var.account_id}/storage/kv/namespaces/f0b474a7601c4e16bf88e3e290db5602/values/VPN_CERTS_R2_DEV_DOMAIN" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        --data-binary "${cloudflare_r2_managed_domain.vpn_certs.domain}"
    EOT
  }
}

resource "cloudflare_r2_bucket" "public" {
  account_id = var.account_id
  name       = "public"
}

resource "cloudflare_r2_custom_domain" "public" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.public.name
  domain      = "public.romashov.tech"
  zone_id     = local.zone_id
  enabled     = true
  min_tls     = "1.2"
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

# Workaround: data "cloudflare_workers_kv" в v5 прогоняет ответ через
# apijson.UnmarshalComputed, который ожидает JSON — plain string тихо возвращает пустую строку.
# Читаем значение напрямую через API и оборачиваем в JSON-объект через jq.
# Issue: https://github.com/cloudflare/terraform-provider-cloudflare/issues/5327
data "external" "slack_grafana_bot_token" {
  program = [
    "bash", "-c",
    "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"https://api.cloudflare.com/client/v4/accounts/${var.account_id}/storage/kv/namespaces/${cloudflare_workers_kv_namespace.romashov_tech.id}/values/slack_grafana_bot_token\" | jq -Rc '{value: .}'"
  ]
}


# ── D1 Databases ─────────────────────────────────────────────────────────────

resource "cloudflare_d1_database" "romashov_tech" {
  account_id = var.account_id
  name       = "romashov-tech"
  read_replication = {
    mode = "disabled"
  }
}
