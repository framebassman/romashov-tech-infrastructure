# OCI VM (Oracle Cloud Infrastructure)

Модуль управляет одной VM в OCI. Подсеть передаётся из корня (`oci_core_subnet.default_vcn.id`). Остальные параметры захардкожены в модуле: compartment, shape (E2.1.Micro), display_name (sweden-node), assign_public_ip (true), availability_domain_index (0).

- Доступ к API — через переменные (tenancy, user, key, region) в `terraform.tfvars`.
- Для существующей VM в `lifecycle` включён `ignore_changes` для `source_details`.

## Ошибка 404 NotAuthorizedOrNotFound

Если `terraform apply` падает с `404-NotAuthorizedOrNotFound`, нужна IAM-политика. В OCI Console: **Identity & Security** → **Identity** → **Policies** → создай политику в tenancy (root compartment):

```
Allow group <твоя_группа> to manage instance-family in tenancy
Allow group <твоя_группа> to manage virtual-network-family in tenancy
```

Или для конкретного compartment:

```
Allow group <твоя_группа> to manage instance-family in compartment <compartment_name>
Allow group <твоя_группа> to manage virtual-network-family in compartment <compartment_name>
```

Группу смотри в **Identity** → **Users** → свой пользователь → Groups.

## Импорт существующей VM

Из корня `terraform/`:

```bash
terraform init -backend-config=backend.conf
terraform import 'module.oci_vm.oci_core_instance.this' '<instance_ocid>'
terraform plan   # при необходимости подправь переменные по выводу
```
