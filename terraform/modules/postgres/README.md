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
| [aiven_pg.this](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg) | resource |
| [aiven_pg_database.defaultdb](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_database) | resource |
| [aiven_pg_database.foodikal_production](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_database) | resource |
| [aiven_pg_database.inventory_production](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_database) | resource |
| [aiven_pg_database.outline](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_database) | resource |
| [aiven_pg_database.postgres](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_database) | resource |
| [aiven_pg_database.vault](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_database) | resource |
| [aiven_pg_user.avnadmin](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_user) | resource |
| [aiven_pg_user.foodikal_user](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_user) | resource |
| [aiven_pg_user.inventory_user](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_user) | resource |
| [aiven_pg_user.outline_user](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_user) | resource |
| [aiven_pg_user.vault_user](https://registry.terraform.io/providers/aiven/aiven/latest/docs/resources/pg_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aiven_api_token"></a> [aiven\_api\_token](#input\_aiven\_api\_token) | Aiven console API token | `string` | n/a | yes |
| <a name="input_pg_avnadmin_user_password"></a> [pg\_avnadmin\_user\_password](#input\_pg\_avnadmin\_user\_password) | Password for Postgres avnadmin user | `string` | n/a | yes |
| <a name="input_pg_foodikal_user_password"></a> [pg\_foodikal\_user\_password](#input\_pg\_foodikal\_user\_password) | Password for Postgres foodikal-user | `string` | n/a | yes |
| <a name="input_pg_inventory_user_password"></a> [pg\_inventory\_user\_password](#input\_pg\_inventory\_user\_password) | Password for Postgres inventory-user | `string` | n/a | yes |
| <a name="input_pg_outline_user_password"></a> [pg\_outline\_user\_password](#input\_pg\_outline\_user\_password) | Password for Postgres outline-user | `string` | n/a | yes |
| <a name="input_pg_vault_user_password"></a> [pg\_vault\_user\_password](#input\_pg\_vault\_user\_password) | Password for Postgres vault-user | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Aiven project name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | The project of the Postgres service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | The name of the Postgres service |
<!-- END_TF_DOCS -->
