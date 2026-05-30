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
      version = "~> 3"
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
  vdsina_api_token = var.vdsina_ru_api_token
}

module "vdsina_com" {
  source           = "./modules/vdsina-com/"
  vdsina_api_token = var.vdsina_com_api_token
}

module "aiven" {
  source                     = "./modules/aiven/"
  aiven_api_token            = var.aiven_api_token
  project_name               = var.project_name
  pg_avnadmin_user_password  = var.pg_avnadmin_user_password
  pg_foodikal_user_password  = var.pg_foodikal_user_password
  pg_inventory_user_password = var.pg_inventory_user_password
  pg_outline_user_password   = var.pg_outline_user_password
  pg_vault_user_password     = var.pg_vault_user_password
  pg_mtproxy_user_password   = var.pg_mtproxy_user_password
}

# OCI: аутентификация из переменных (terraform.tfvars или backend.conf)
provider "oci" {
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
  fingerprint  = var.oci_fingerprint
  private_key  = var.oci_private_key
  region       = "eu-stockholm-1"
}

module "oci" {
  source       = "./modules/oci/"
  tenancy_ocid = var.oci_tenancy_ocid
  group_name   = "Administrators"
}

# ── Grafana Cloud (Synthetic Monitoring + Alerting) ──────────────────────────
# Replaces self-hosted Uptime Kuma on node1. See modules/grafana-monitoring/README.md.
provider "grafana" {
  url             = "https://${var.grafana_stack_slug}.grafana.net"
  auth            = var.grafana_cloud_api_key
  sm_url          = "https://synthetic-monitoring-api-eu-west-2.grafana.net"
  sm_access_token = var.grafana_synthetic_monitoring_token
}

module "grafana_monitoring" {
  source          = "./modules/grafana-monitoring/"
  stack_slug      = var.grafana_stack_slug
  slack_bot_token = module.cloudflare.slack_grafana_bot_token
  slack_channel   = "general"
}
