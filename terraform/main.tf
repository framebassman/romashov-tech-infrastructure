terraform {
  required_version = ">=1.14"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 8"
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

module "aiven_mysql" {
  source                         = "./modules/aiven-mysql/"
  aiven_api_token                = var.aiven_api_token
  project_name                   = var.project_name
  mysql_avnadmin_user_password   = var.mysql_avnadmin_user_password
  mysql_monitoring_user_password = var.mysql_monitoring_user_password
}

module "aiven_postgres" {
  source                     = "./modules/aiven-postgres/"
  aiven_api_token            = var.aiven_api_token
  project_name               = var.project_name
  pg_avnadmin_user_password  = var.pg_avnadmin_user_password
  pg_foodikal_user_password  = var.pg_foodikal_user_password
  pg_inventory_user_password = var.pg_inventory_user_password
  pg_outline_user_password   = var.pg_outline_user_password
  pg_vault_user_password     = var.pg_vault_user_password
}

# OCI: аутентификация из переменных (terraform.tfvars или backend.conf)
provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key      = var.oci_private_key
  region           = var.oci_region
}

# IAM-политика для создания VM (создаётся первой, затем VM)
module "oci_iam" {
  source       = "./modules/oci-iam/"
  tenancy_ocid = var.oci_tenancy_ocid
  group_name   = var.oci_iam_group_name
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

  depends_on = [module.oci_iam]
}
