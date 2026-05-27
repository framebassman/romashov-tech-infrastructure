# /etc/environment is only loaded by PAM at login — export explicitly so terraform subprocesses see it
CLOUDFLARE_API_TOKEN ?= $(shell grep -m1 '^CLOUDFLARE_API_TOKEN=' /etc/environment 2>/dev/null | cut -d= -f2-)
export CLOUDFLARE_API_TOKEN

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

import-cf:
	@echo "--- Cloudflare: zone ---"
	-terraform import module.cloudflare.cloudflare_zone.romashov_tech 6d25afe4e74dea9603251aae7971f49f
	@echo "--- Cloudflare: DNS records ---"
	-terraform import 'module.cloudflare.cloudflare_record.a_alloy' '6d25afe4e74dea9603251aae7971f49f/4ae51bf88222db07328f15a6f72aff8e'
	-terraform import 'module.cloudflare.cloudflare_record.a_dash' '6d25afe4e74dea9603251aae7971f49f/46706dd6b9a124723e51af04898d14bb'
	-terraform import 'module.cloudflare.cloudflare_record.a_in_3x' '6d25afe4e74dea9603251aae7971f49f/09a4c5fc355933fd434743df072cf177'
	-terraform import 'module.cloudflare.cloudflare_record.a_in' '6d25afe4e74dea9603251aae7971f49f/5a9f66e83cf050c916a773a74515b6dc'
	-terraform import 'module.cloudflare.cloudflare_record.a_node1' '6d25afe4e74dea9603251aae7971f49f/ae6f92f1f8a0cc9cfab7627f23a7db1b'
	-terraform import 'module.cloudflare.cloudflare_record.a_node2' '6d25afe4e74dea9603251aae7971f49f/d4b4902abe137ac4fc1e87d88cab4047'
	-terraform import 'module.cloudflare.cloudflare_record.a_node3' '6d25afe4e74dea9603251aae7971f49f/c103e840258747878e5f73425219ed3e'
	-terraform import 'module.cloudflare.cloudflare_record.a_node4' '6d25afe4e74dea9603251aae7971f49f/eee7a1426e8f2bbb8ddcd4607b262cbe'
	-terraform import 'module.cloudflare.cloudflare_record.a_out_3x' '6d25afe4e74dea9603251aae7971f49f/a501c1b686341b58bb556e70ede13936'
	-terraform import 'module.cloudflare.cloudflare_record.a_out' '6d25afe4e74dea9603251aae7971f49f/2e8aaf9ee437591443dd6ccdbc84c537'
	-terraform import 'module.cloudflare.cloudflare_record.a_russia' '6d25afe4e74dea9603251aae7971f49f/2a01dc26684172bd72071e1f2249489c'
	-terraform import 'module.cloudflare.cloudflare_record.a_tg' '6d25afe4e74dea9603251aae7971f49f/230ade4025a7877acc93a89af3927070'
	-terraform import 'module.cloudflare.cloudflare_record.a_v2_tg' '6d25afe4e74dea9603251aae7971f49f/be80d2fc48d2cceb04e35eb45e4e7574'
	-terraform import 'module.cloudflare.cloudflare_record.a_v3_tg' '6d25afe4e74dea9603251aae7971f49f/41aae95dcb396589f5e7672943e58176'
	-terraform import 'module.cloudflare.cloudflare_record.a_vault' '6d25afe4e74dea9603251aae7971f49f/907ba74a712bdd7e3d8f79cd902b8a12'
	-terraform import 'module.cloudflare.cloudflare_record.a_vpn' '6d25afe4e74dea9603251aae7971f49f/6c30c78104dc5eb03f5a0c2a69817507'
	-terraform import 'module.cloudflare.cloudflare_record.a_www' '6d25afe4e74dea9603251aae7971f49f/69df813ad481dc30c215c8774433ecc4'
	-terraform import 'module.cloudflare.cloudflare_record.cname_apex' '6d25afe4e74dea9603251aae7971f49f/1903d454033e73be6696463860e0f6bc'
	-terraform import 'module.cloudflare.cloudflare_record.cname_webhook' '6d25afe4e74dea9603251aae7971f49f/1325914821e1844672bc3a9887d0566a'
	-terraform import 'module.cloudflare.cloudflare_record.mx_apex' '6d25afe4e74dea9603251aae7971f49f/eb136a1d8a5e6fad30ddc4342c6542ff'
	-terraform import 'module.cloudflare.cloudflare_record.txt_acme_challenge_m_inventory' '6d25afe4e74dea9603251aae7971f49f/20ffddaa790af2506f1b44b5d26f861b'
	-terraform import 'module.cloudflare.cloudflare_record.txt_mail_dkim' '6d25afe4e74dea9603251aae7971f49f/c66d397028d375a10bb11b353918e7d5'
	-terraform import 'module.cloudflare.cloudflare_record.txt_apex_spf' '6d25afe4e74dea9603251aae7971f49f/d7c818240ee028f50c95301a4931128d'
	@echo "--- Cloudflare: R2 / KV / Pages ---"
	-terraform import module.cloudflare.cloudflare_r2_bucket.backups 4faf2c3b5dd13669f97dd976498ad56a/backups
	-terraform import module.cloudflare.cloudflare_r2_bucket.vpn_certs 4faf2c3b5dd13669f97dd976498ad56a/vpn-certs
	-terraform import module.cloudflare.cloudflare_r2_bucket.terraform_backend 4faf2c3b5dd13669f97dd976498ad56a/kolenka-inc-terraform-backend
	-terraform import module.cloudflare.cloudflare_workers_kv_namespace.romashov_tech 4faf2c3b5dd13669f97dd976498ad56a/f0b474a7601c4e16bf88e3e290db5602
	-terraform import module.cloudflare.cloudflare_pages_project.romashov_tech_web 4faf2c3b5dd13669f97dd976498ad56a/romashov-tech-web
	-terraform import module.cloudflare.cloudflare_pages_project.romashov_tech_status 4faf2c3b5dd13669f97dd976498ad56a/romashov-tech-status
	-terraform import module.cloudflare.cloudflare_pages_domain.status_romashov_tech 4faf2c3b5dd13669f97dd976498ad56a/romashov-tech-status/status.romashov.tech

# Импорт: уже импортированные ресурсы могут вернуть ошибку — make продолжит (префикс -)
import:
	$(MAKE) import-cf
	@echo "--- VDSina.ru ---"
	-terraform import module.vdsina_ru.vdsina_ssh_key.all_together 29258
	-terraform import module.vdsina_ru.vdsina_ssh_key.romashov_komplukter 28741
	-terraform import module.vdsina_ru.vdsina_ssh_key.romashov_workstation 28742
	-terraform import module.vdsina_ru.vdsina_ssh_key.github_komplukter 29257
	-terraform import module.vdsina_ru.vdsina_server.node2 3017377
	@echo "--- VDSina.com ---"
	-terraform import module.vdsina_com.vdsina_ssh_key.romashov_komplukter 366
	-terraform import module.vdsina_com.vdsina_ssh_key.romashov_workstation 369
	-terraform import module.vdsina_com.vdsina_ssh_key.pixel 368
	-terraform import module.vdsina_com.vdsina_ssh_key.pixel_biometric 367
	-terraform import module.vdsina_com.vdsina_server.node1 598372
	-terraform import module.vdsina_com.vdsina_server.out_3x 820792
	@echo "--- Aiven ---"
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
