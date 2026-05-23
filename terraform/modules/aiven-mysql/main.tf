# Module retained only while terraform tears down the Aiven MySQL service.
# Aiven refuses to delete the built-in avnadmin user and defaultdb database
# via API (403 — tied to the service lifecycle), but destroys them server-side
# when the service itself is destroyed. So we forget them from state with
# destroy = false and let aiven_mysql.this destroy as an implicit orphan.
# Remove this entire module in the follow-up PR after apply.

removed {
  from = aiven_mysql_user.avnadmin
  lifecycle {
    destroy = false
  }
}

removed {
  from = aiven_mysql_database.defaultdb
  lifecycle {
    destroy = false
  }
}
