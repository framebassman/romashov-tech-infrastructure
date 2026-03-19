# kolenkainc-infrastructure

## Модули

- **aiven-mysql** — Aiven MySQL (сервис, БД, пользователи)
- **aiven-postgres** — Aiven Postgres (сервис, БД, пользователи). В том числе БД **mtproxy-production** и пользователь **mtproxy-production** для хранения секретов MTProxy (права CONNECT/CREATE на БД и USAGE/CREATE на схему public выдаются при apply через null_resource + psql под avnadmin).
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

## Ограничение доступа к метрикам ocserv-exporter (VPN-ноды)

На VPN-нодах порт 8000 (Docker → ocserv-exporter) доступен только с Alloy (sweden-node). Используется iptables цепочка **DOCKER-USER** (трафик к контейнерам не проходит через UFW INPUT). IP sweden-node берётся из инвентаря (группа `sweden`).

```bash
cd ansible
ansible-playbook -i hosts.yml playbooks/vpn-firewall.yml
```

Откат (порт 8000 снова для всех): `ansible-playbook -i hosts.yml playbooks/vpn-firewall-rollback.yml`
