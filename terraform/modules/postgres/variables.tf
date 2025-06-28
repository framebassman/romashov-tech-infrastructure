variable "aiven_api_token" {
  description = "Aiven console API token"
  type        = string
}

variable "project_name" {
  description = "Aiven project name"
  type        = string
}

variable "pg_avnadmin_user_password" {
  description = "Password for Postgres avnadmin user"
  type        = string
}

variable "pg_foodikal_user_password" {
  description = "Password for Postgres foodikal-user"
  type        = string
}

variable "pg_inventory_user_password" {
  description = "Password for Postgres inventory-user"
  type        = string
}

variable "pg_outline_user_password" {
  description = "Password for Postgres outline-user"
  type        = string
}

variable "pg_vault_user_password" {
  description = "Password for Postgres vault-user"
  type        = string
}