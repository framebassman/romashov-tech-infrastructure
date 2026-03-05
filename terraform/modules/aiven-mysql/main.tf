# MySQL service module

resource "aiven_mysql" "this" {
  project      = var.project_name
  service_name = "kolenka-inc-mysql"
  cloud_name   = "upcloud-nl-ams"
  plan         = "free-1-1gb"

  mysql_user_config {
    mysql_version = 8

    mysql {
      sql_mode                = "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES"
      sql_require_primary_key = true
    }
  }
}

resource "aiven_mysql_database" "defaultdb" {
  project       = aiven_mysql.this.project
  service_name  = aiven_mysql.this.service_name
  database_name = "defaultdb"
}

resource "aiven_mysql_user" "avnadmin" {
  project      = aiven_mysql.this.project
  service_name = aiven_mysql.this.service_name
  username     = "avnadmin"
  password     = var.mysql_avnadmin_user_password
}

resource "aiven_mysql_database" "monitoring" {
  project       = aiven_mysql.this.project
  service_name  = aiven_mysql.this.service_name
  database_name = "monitoring"
}

resource "aiven_mysql_user" "monitoring_user" {
  project      = aiven_mysql.this.project
  service_name = aiven_mysql.this.service_name
  username     = "monitoring-user"
  password     = var.mysql_monitoring_user_password
}
