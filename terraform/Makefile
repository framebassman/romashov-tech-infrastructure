init:
	terraform init \
		-backend-config=backend.conf

plan:
	terraform plan

apply:
	terraform apply -auto-approve

pull:
	terraform state pull

fmt:
	terraform fmt

# Импорт: уже импортированные ресурсы могут вернуть ошибку — make продолжит (префикс -)
import:
	-terraform import module.aiven_mysql.aiven_mysql.this romashov-tech/kolenka-inc-mysql
	-terraform import module.aiven_mysql.aiven_mysql_database.defaultdb romashov-tech/kolenka-inc-mysql/defaultdb
	-terraform import module.aiven_mysql.aiven_mysql_user.avnadmin romashov-tech/kolenka-inc-mysql/avnadmin
	-terraform import module.aiven_mysql.aiven_mysql_database.monitoring romashov-tech/kolenka-inc-mysql/monitoring
	-terraform import module.aiven_mysql.aiven_mysql_user.monitoring_user romashov-tech/kolenka-inc-mysql/monitoring-user
	-terraform import module.aiven_postgres.aiven_pg.this romashov-tech/romashov-tech-postgres
	-terraform import module.aiven_postgres.aiven_pg_database.postgres romashov-tech/romashov-tech-postgres/postgres
	-terraform import module.aiven_postgres.aiven_pg_database.defaultdb romashov-tech/romashov-tech-postgres/defaultdb
	-terraform import module.aiven_postgres.aiven_pg_user.avnadmin romashov-tech/romashov-tech-postgres/avnadmin
	-terraform import module.aiven_postgres.aiven_pg_database.inventory_production romashov-tech/romashov-tech-postgres/inventory-production
	-terraform import module.aiven_postgres.aiven_pg_user.inventory_user romashov-tech/romashov-tech-postgres/inventory-user
	-terraform import module.aiven_postgres.aiven_pg_database.outline romashov-tech/romashov-tech-postgres/romashov-tech-outline
	-terraform import module.aiven_postgres.aiven_pg_user.outline_user romashov-tech/romashov-tech-postgres/outline-user
	-terraform import module.aiven_postgres.aiven_pg_database.vault romashov-tech/romashov-tech-postgres/romashov-tech-vault
	-terraform import module.aiven_postgres.aiven_pg_user.vault_user romashov-tech/romashov-tech-postgres/vault-user
	-terraform import module.aiven_postgres.aiven_pg_database.mtproxy_production romashov-tech/romashov-tech-postgres/mtproxy-production
	-terraform import module.aiven_postgres.aiven_pg_user.mtproxy_user romashov-tech/romashov-tech-postgres/mtproxy-production
	@echo "--- OCI VM ---"
	terraform import 'module.oci_vm.oci_core_instance.this' 'ocid1.instance.oc1.eu-stockholm-1.anqxeljryneafxycu45rfs7efir6uaw6cmpydknxiw25ph35fil254kkejgq'

import-oci:
	terraform import 'module.oci_vm.oci_core_instance.this' 'ocid1.instance.oc1.eu-stockholm-1.anqxeljryneafxycu45rfs7efir6uaw6cmpydknxiw25ph35fil254kkejgq'
