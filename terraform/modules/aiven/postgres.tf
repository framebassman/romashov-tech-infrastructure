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

# MTProxy: отдельная БД и пользователь для хранения секретов MTProxy
resource "aiven_pg_database" "mtproxy_production" {
  project       = aiven_pg.this.project
  service_name  = aiven_pg.this.service_name
  database_name = "mtproxy-production"
}

resource "aiven_pg_user" "mtproxy_user" {
  project              = aiven_pg.this.project
  service_name         = aiven_pg.this.service_name
  username             = "mtproxy-production"
  password             = var.pg_mtproxy_user_password
  pg_allow_replication = false
}

# Права пользователя mtproxy-production на БД mtproxy-production (CONNECT + CREATE на БД и схему public).
# Выполняется через psql под avnadmin (service_uri), т.к. Aiven не даёт выдать права через Terraform provider.
resource "null_resource" "mtproxy_grants" {
  depends_on = [
    aiven_pg_database.mtproxy_production,
    aiven_pg_user.mtproxy_user,
  ]
  triggers = {
    db   = aiven_pg_database.mtproxy_production.database_name
    user = aiven_pg_user.mtproxy_user.username
  }
  provisioner "local-exec" {
    environment = {
      PGCONN_POSTGRES = replace(aiven_pg.this.service_uri, "defaultdb", "postgres")
      PGCONN_MTPROXY  = replace(aiven_pg.this.service_uri, "defaultdb", "mtproxy-production")
    }
    command     = "psql \"$PGCONN_POSTGRES\" -v ON_ERROR_STOP=1 -c 'GRANT CONNECT, CREATE ON DATABASE \"mtproxy-production\" TO \"mtproxy-production\";' && psql \"$PGCONN_MTPROXY\" -v ON_ERROR_STOP=1 -c 'GRANT USAGE, CREATE ON SCHEMA public TO \"mtproxy-production\";'"
    interpreter = ["bash", "-c"]
  }
}
