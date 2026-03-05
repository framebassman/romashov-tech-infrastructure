# kolenkainc-infrastructure

## Модули

- **aiven-mysql** — Aiven MySQL (сервис, БД, пользователи)
- **aiven-postgres** — Aiven Postgres (сервис, БД, пользователи)

## Миграция state после переименования модулей (mysql → aiven_mysql, postgres → aiven_postgres)

Если у тебя уже есть state с прежними именами модулей, выполни один раз:

```bash
cd terraform
terraform state mv 'module.mysql' 'module.aiven_mysql'
terraform state mv 'module.postgres' 'module.aiven_postgres'
```

После этого `terraform plan` не должен предлагать пересоздавать ресурсы.
