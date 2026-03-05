# OCI VM (Oracle Cloud Infrastructure)

Модуль управляет одной VM в OCI.

- Доступ к API — через `~/.oci/config` (переменные только для compartment/region/образ).
- После добавления инстанса в state через `terraform import` конфиг можно не менять: для существующей VM в `lifecycle` включён `ignore_changes` для `source_details` и `create_vnic_details`.

## Импорт существующей VM

Из корня `terraform/`:

```bash
terraform init -backend-config=backend.conf
terraform import 'module.oci_vm.oci_core_instance.this' '<instance_ocid>'
terraform plan   # при необходимости подправь переменные по выводу
```

Если нужен конкретный образ (например, после импорта plan показывает смену образа), задай `oci_instance_image_id` в `terraform.tfvars`. Узнать image OCID текущей VM:

```bash
oci compute instance get --instance-id <instance_ocid> --query 'data."source-details"."image-id"' --raw-output
```
