<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13 |
| <a name="requirement_aiven"></a> [aiven](#requirement\_aiven) | >=4.0.0, <5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aiven"></a> [aiven](#provider\_aiven) | >=4.0.0, <5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aiven_mysql.this](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/mysql) | resource |
| [aiven_mysql_database.defaultdb](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/mysql_database) | resource |
| [aiven_mysql_database.monitoring](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/mysql_database) | resource |
| [aiven_mysql_user.avnadmin](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/mysql_user) | resource |
| [aiven_mysql_user.monitoring_user](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/mysql_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aiven_api_token"></a> [aiven\_api\_token](#input\_aiven\_api\_token) | Aiven console API token | `string` | n/a | yes |
| <a name="input_mysql_avnadmin_user_password"></a> [mysql\_avnadmin\_user\_password](#input\_mysql\_avnadmin\_user\_password) | Password for MySQL avnadmin user | `string` | n/a | yes |
| <a name="input_mysql_monitoring_user_password"></a> [mysql\_monitoring\_user\_password](#input\_mysql\_monitoring\_user\_password) | Password for MySQL monitoring-user | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Aiven project name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | The project of the MySQL service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | The name of the MySQL service |
<!-- END_TF_DOCS -->
