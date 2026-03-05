# Postgres service module

resource "aiven_pg" "this" {
  project      = var.project_name
  service_name = "romashov-tech-postgres"
  plan         = "free-1-5gb"
  cloud_name   = "do-fra"
}

resource "aiven_pg_database" "postgres" {
  project       = aiven_pg.this.project
  service_name  = aiven_pg.this.service_name
  database_name = "postgres"
}

resource "aiven_pg_database" "defaultdb" {
  project       = aiven_pg.this.project
  service_name  = aiven_pg.this.service_name
  database_name = "defaultdb"
}

resource "aiven_pg_user" "avnadmin" {
  project              = aiven_pg.this.project
  service_name         = aiven_pg.this.service_name
  username             = "avnadmin"
  password             = var.pg_avnadmin_user_password
  pg_allow_replication = true
}

resource "aiven_pg_database" "inventory_production" {
  project       = aiven_pg.this.project
  service_name  = aiven_pg.this.service_name
  database_name = "inventory-production"
}

resource "aiven_pg_user" "inventory_user" {
  project              = aiven_pg.this.project
  service_name         = aiven_pg.this.service_name
  username             = "inventory-user"
  password             = var.pg_inventory_user_password
  pg_allow_replication = false
}

resource "aiven_pg_database" "outline" {
  project       = aiven_pg.this.project
  service_name  = aiven_pg.this.service_name
  database_name = "romashov-tech-outline"
  lc_collate    = "en_US.utf8"
  lc_ctype      = "en_US.utf8"
}

resource "aiven_pg_user" "outline_user" {
  project              = aiven_pg.this.project
  service_name         = aiven_pg.this.service_name
  username             = "outline-user"
  password             = var.pg_outline_user_password
  pg_allow_replication = false
}

resource "aiven_pg_database" "vault" {
  project       = aiven_pg.this.project
  service_name  = aiven_pg.this.service_name
  database_name = "romashov-tech-vault"
}

resource "aiven_pg_user" "vault_user" {
  project              = aiven_pg.this.project
  service_name         = aiven_pg.this.service_name
  username             = "vault-user"
  password             = var.pg_vault_user_password
  pg_allow_replication = false
}
