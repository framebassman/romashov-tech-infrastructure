output "service_name" {
  description = "The name of the MySQL service"
  value       = aiven_mysql.this.service_name
}

output "project" {
  description = "The project of the MySQL service"
  value       = aiven_mysql.this.project
}