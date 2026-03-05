terraform {
  required_version = ">=0.13"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 5"
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

module "oci_vm" {
  source             = "./modules/oci-vm/"
  compartment_id     = var.oci_compartment_id
  instance_shape     = var.oci_instance_shape
  instance_image_id  = var.oci_instance_image_id
}
