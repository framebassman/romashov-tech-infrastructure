init:
	terraform init -backend-config=backend.conf

plan:
	terraform plan

apply:
	terraform apply

pull:
	terraform state pull

fmt:
	terraform fmt

import:
	terraform import module.mysql.aiven_mysql.this romashov-tech/kolenka-inc-mysql
	terraform import module.mysql.aiven_mysql_database.defaultdb romashov-tech/kolenka-inc-mysql/defaultdb
	terraform import module.mysql.aiven_mysql_user.avnadmin romashov-tech/kolenka-inc-mysql/avnadmin
	terraform import module.mysql.aiven_mysql_database.monitoring romashov-tech/kolenka-inc-mysql/monitoring
	terraform import module.mysql.aiven_mysql_user.monitoring_user romashov-tech/kolenka-inc-mysql/monitoring-user
	terraform import module.postgres.aiven_pg.this romashov-tech/romashov-tech-postgres
	terraform import module.postgres.aiven_pg_database.postgres romashov-tech/romashov-tech-postgres/postgres
	terraform import module.postgres.aiven_pg_database.defaultdb romashov-tech/romashov-tech-postgres/defaultdb
	terraform import module.postgres.aiven_pg_user.avnadmin romashov-tech/romashov-tech-postgres/avnadmin
	terraform import module.postgres.aiven_pg_database.foodikal_production romashov-tech/romashov-tech-postgres/foodikal-production
	terraform import module.postgres.aiven_pg_user.foodikal_user romashov-tech/romashov-tech-postgres/foodikal-user
	terraform import module.postgres.aiven_pg_database.inventory_production romashov-tech/romashov-tech-postgres/inventory-production
	terraform import module.postgres.aiven_pg_user.inventory_user romashov-tech/romashov-tech-postgres/inventory-user
	terraform import module.postgres.aiven_pg_database.outline romashov-tech/romashov-tech-postgres/romashov-tech-outline
	terraform import module.postgres.aiven_pg_user.outline_user romashov-tech/romashov-tech-postgres/outline-user
	terraform import module.postgres.aiven_pg_database.vault romashov-tech/romashov-tech-postgres/romashov-tech-vault
	terraform import module.postgres.aiven_pg_user.vault_user romashov-tech/romashov-tech-postgres/vault-user
