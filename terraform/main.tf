terraform {
  required_version = ">=1.14"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 8"
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
  alloy_public_ip = module.oci_vm.instance_public_ip
}

module "vdsina_ru" {
  source           = "./modules/vdsina-ru/"
  vdsina_api_token = var.vdsina_ru_api_token
}

module "vdsina_com" {
  source           = "./modules/vdsina-com/"
  vdsina_api_token = var.vdsina_com_api_token
}

module "aiven_postgres" {
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

# IAM-политика для создания VM (создаётся первой, затем VM)
module "oci_iam" {
  source       = "./modules/oci-iam/"
  tenancy_ocid = var.oci_tenancy_ocid
  group_name   = "Administrators"
}

# Существующая VCN vcn-20250808-1700 — создаём в ней подсеть
locals {
  oci_compartment_id = "ocid1.tenancy.oc1..aaaaaaaamw5qcdprotjyd7tjbxuijfmjpdxndosth5wiul6ag2m54wqhnzna"
}

data "oci_core_vcns" "default" {
  compartment_id = local.oci_compartment_id
  display_name   = "vcn-20250808-1700"
}

resource "oci_core_subnet" "default_vcn" {
  compartment_id             = local.oci_compartment_id
  vcn_id                     = data.oci_core_vcns.default.virtual_networks[0].id
  cidr_block                 = "10.0.0.0/24"
  display_name               = "default-vcn-subnet"
  dns_label                  = "defaultsub"
  prohibit_public_ip_on_vnic = false
}

module "oci_vm" {
  source    = "./modules/oci-vm/"
  subnet_id = oci_core_subnet.default_vcn.id
  nsg_ids   = [oci_core_network_security_group.sweden_inbound.id]

  depends_on = [module.oci_iam]
}

# Hosts the OTLP/HTTP receiver port (4318) for Grafana Alloy. Ingress is
# restricted to node2 (RU) — the only client that pushes traces. Subnet's
# default security list still only allows :22 + ICMP; NSG UNIONs with it.
resource "oci_core_network_security_group" "sweden_inbound" {
  compartment_id = local.oci_compartment_id
  vcn_id         = data.oci_core_vcns.default.virtual_networks[0].id
  display_name   = "sweden-inbound"
}

# node2.romashov.tech (RU edge running Traefik) -> Alloy OTLP receiver.
resource "oci_core_network_security_group_security_rule" "sweden_inbound_otlp_http_from_node2" {
  network_security_group_id = oci_core_network_security_group.sweden_inbound.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "109.172.90.19/32"
  source_type               = "CIDR_BLOCK"
  description               = "OTLP/HTTP from node2 Traefik tracing"

  tcp_options {
    destination_port_range {
      min = 4318
      max = 4318
    }
  }
}

# Vault on sweden1 listens plain HTTP; Cloudflare fronts vault.romashov.tech
# (proxied=true) and connects to the origin over HTTP in SSL mode "Flexible".
# Client-facing TLS terminates at CF's edge with the Universal cert.
# Trade-off: the CF→origin leg is plaintext over the public internet;
# acceptable here because this Vault is a backup secret store (primary is
# Cloudflare KV) and Vault's own auth is the real access control regardless.
resource "oci_core_network_security_group_security_rule" "sweden_inbound_http_vault" {
  network_security_group_id = oci_core_network_security_group.sweden_inbound.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP for Vault (Cloudflare-fronted, Flexible SSL mode)"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Бюджет $5 и алерт при достижении (для контроля расходов при PAYG)
resource "oci_budget_budget" "monthly_limit" {
  compartment_id = var.oci_tenancy_ocid
  amount         = 5
  reset_period   = "MONTHLY"
  display_name   = "monthly-5usd-limit"
  description    = "Alert when spend reaches $5 (PAYG safety)"
  target_type    = "COMPARTMENT"
  targets        = [var.oci_tenancy_ocid]
}

resource "oci_budget_alert_rule" "at_5_usd" {
  budget_id      = oci_budget_budget.monthly_limit.id
  display_name   = "alert-at-5-usd"
  threshold      = 5
  threshold_type = "ABSOLUTE"
  type           = "ACTUAL"
  message        = "OCI spend has reached $5 this month. Check Cost Analysis in Console."
  recipients     = "dmitry@romashov.tech"
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
  slack_bot_token = var.slack_grafana_bot_token
  slack_channel   = "general"
}
