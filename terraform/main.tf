terraform {
  required_version = ">=1.14"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.17"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 8.16"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.29"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2"
    }
  }

  backend "s3" {
    bucket                      = "kolenka-inc-terraform-backend"
    key                         = "terraform.tfstate"
    endpoints                   = { s3 = "https://4faf2c3b5dd13669f97dd976498ad56a.r2.cloudflarestorage.com" }
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true
  }
}

variable "account_id" { default = "4faf2c3b5dd13669f97dd976498ad56a" }

# api_token is read from CLOUDFLARE_API_TOKEN env var (exported in Makefile from /etc/environment)
provider "cloudflare" {}

module "cloudflare" {
  source          = "./modules/cloudflare/"
  account_id      = var.account_id
  alloy_public_ip = module.oci.instance_public_ip
}

module "vdsina_ru" {
  source           = "./modules/vdsina-ru/"
  vdsina_api_token = data.external.vdsina_ru_api_token.result.value
}

module "aiven" {
  source                     = "./modules/aiven/"
  aiven_api_token            = data.external.aiven_api_token.result.value
  project_name               = "romashov-tech"
  pg_avnadmin_user_password  = data.external.pg_avnadmin_user_password.result.value
  pg_foodikal_user_password  = data.external.pg_foodikal_user_password.result.value
  pg_inventory_user_password = data.external.pg_inventory_user_password.result.value
  pg_outline_user_password   = data.external.pg_outline_user_password.result.value
  pg_vault_user_password     = data.external.pg_vault_user_password.result.value
  pg_mtproxy_user_password   = data.external.pg_mtproxy_user_password.result.value
  pg_lubelog_user_password   = data.external.pg_lubelog_user_password.result.value
}

# OCI: аутентификация из переменных (terraform.tfvars или backend.conf)
provider "oci" {
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
  fingerprint  = var.oci_fingerprint
  private_key  = data.external.oci_private_key.result.value
  region       = "eu-stockholm-1"
}

module "oci" {
  source       = "./modules/oci/"
  tenancy_ocid = var.oci_tenancy_ocid
  group_name   = "Administrators"
}

# ── Grafana Cloud (Synthetic Monitoring + Alerting) ──────────────────────────
# Replaces self-hosted Uptime Kuma on node1. See modules/grafana-monitoring/README.md.
locals {
  kv_base_url = "https://api.cloudflare.com/client/v4/accounts/${var.account_id}/storage/kv/namespaces/f0b474a7601c4e16bf88e3e290db5602/values"
}

data "external" "vdsina_ru_api_token" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/vdsina_ru_api_token\" | jq -Rc '{value: .}'"]
}

data "external" "aiven_api_token" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/aiven_api_token\" | jq -Rc '{value: .}'"]
}

data "external" "pg_avnadmin_user_password" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_avnadmin_user_password\" | jq -Rc '{value: .}'"]
}

data "external" "pg_foodikal_user_password" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_foodikal_user_password\" | jq -Rc '{value: .}'"]
}

data "external" "pg_inventory_user_password" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_inventory_user_password\" | jq -Rc '{value: .}'"]
}

data "external" "pg_outline_user_password" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_outline_user_password\" | jq -Rc '{value: .}'"]
}

data "external" "pg_vault_user_password" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_vault_user_password\" | jq -Rc '{value: .}'"]
}

data "external" "oci_private_key" {
  program = ["bash", "-c", "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/oci_private_key\" | jq -Rs '{value: .}'"]
}

data "external" "pg_mtproxy_user_password" {
  program = [
    "bash", "-c",
    "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_mtproxy_user_password\" | jq -Rc '{value: .}'"
  ]
}

data "external" "pg_lubelog_user_password" {
  program = [
    "bash", "-c",
    "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/pg_lubelog_user_password\" | jq -Rc '{value: .}'"
  ]
}

data "external" "grafana_cloud_api_key" {
  program = [
    "bash", "-c",
    "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/grafana_cloud_api_key\" | jq -Rc '{value: .}'"
  ]
}

data "external" "grafana_synthetic_monitoring_token" {
  program = [
    "bash", "-c",
    "curl -sf -H \"Authorization: Bearer $CLOUDFLARE_API_TOKEN\" \"${local.kv_base_url}/GRAFANA_SYNTHETIC_MONITORING_TOKEN\" | jq -Rc '{value: .}'"
  ]
}

provider "grafana" {
  url             = "https://${var.grafana_stack_slug}.grafana.net"
  auth            = data.external.grafana_cloud_api_key.result.value
  sm_url          = "https://synthetic-monitoring-api-eu-west-2.grafana.net"
  sm_access_token = data.external.grafana_synthetic_monitoring_token.result.value
}

module "grafana_monitoring" {
  source          = "./modules/grafana-monitoring/"
  stack_slug      = var.grafana_stack_slug
  slack_bot_token = module.cloudflare.slack_grafana_bot_token
  slack_channel   = "general"
}
