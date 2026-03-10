# kolenkainc-infrastructure

## Модули

- **aiven-mysql** — Aiven MySQL (сервис, БД, пользователи)
- **aiven-postgres** — Aiven Postgres (сервис, БД, пользователи)
- **oci-iam** — IAM-политика для compute/network
- **oci-vm** — Oracle Cloud (одна VM sweden-node, Ubuntu 22.04). VM и подсеть в существующей VCN **vcn-20250808-1700** (подсеть создаётся Terraform, если в VCN её ещё нет).

### Бюджет и алерт при $5 (PAYG)

В корне создаётся бюджет **$5/месяц** и алерт на захардкоженный email при достижении $5 фактических расходов. Нужны права на Budgets в tenancy (например, `manage budget in tenancy`).

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

## Метрики ocserv-exporter (VPN-ноды)

Доступ к метрикам на порту 8000 защищён секретным путём в URL (nginx-прокси). UFW и firewall-плейбук не используются. Плейбук `vpn-firewall.yml` при деплое только снимает старые артефакты (DOCKER-USER, скрипт), если они были.
