terraform {
  required_version = ">=0.13"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }

  backend "s3" {
    bucket                      = "kolenka-inc-terraform-backend"
    key                         = "terraform.tfstate"
    endpoint                    = "https://4faf2c3b5dd13669f97dd976498ad56a.r2.cloudflarestorage.com"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

variable "account_id" { default = "4faf2c3b5dd13669f97dd976498ad56a" }

module "mysql" {
  source                         = "./modules/mysql/"
  aiven_api_token                = var.aiven_api_token
  project_name                   = var.project_name
  mysql_avnadmin_user_password   = var.mysql_avnadmin_user_password
  mysql_monitoring_user_password = var.mysql_monitoring_user_password
}

module "postgres" {
  source                     = "./modules/postgres/"
  aiven_api_token            = var.aiven_api_token
  project_name               = var.project_name
  pg_avnadmin_user_password  = var.pg_avnadmin_user_password
  pg_foodikal_user_password  = var.pg_foodikal_user_password
  pg_inventory_user_password = var.pg_inventory_user_password
  pg_outline_user_password   = var.pg_outline_user_password
  pg_vault_user_password     = var.pg_vault_user_password
}
