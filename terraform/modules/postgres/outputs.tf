output "service_name" {
  description = "The name of the Postgres service"
  value       = aiven_pg.this.service_name
}

output "project" {
  description = "The project of the Postgres service"
  value       = aiven_pg.this.project
}