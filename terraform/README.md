# kolenkainc-infrastructure

## Модули

- **aiven-mysql** — Aiven MySQL (сервис, БД, пользователи)
- **aiven-postgres** — Aiven Postgres (сервис, БД, пользователи)
- **oci-vm** — Oracle Cloud (одна VM; доступ задаётся в `terraform.tfvars`: tenancy, user, fingerprint, private_key_path, region)

## Миграция state после переименования модулей (mysql → aiven_mysql, postgres → aiven_postgres)

Если у тебя уже есть state с прежними именами модулей, выполни один раз:

```bash
cd terraform
terraform state mv 'module.mysql' 'module.aiven_mysql'
terraform state mv 'module.postgres' 'module.aiven_postgres'
```

После этого `terraform plan` не должен предлагать пересоздавать ресурсы.

### После переименования модуля oci → oci_vm

Если OCI VM уже была импортирована как `module.oci`:

```bash
terraform state mv 'module.oci' 'module.oci_vm'
```
