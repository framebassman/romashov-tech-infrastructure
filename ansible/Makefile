requirements:
	ansible-galaxy install -r requirements.yml

infrastructure:
	make requirements
	ansible-playbook playbooks/infrastructure.yml \
		--extra-vars CLOUDFLARE_API_TOKEN=$${CLOUDFLARE_API_TOKEN}

deploy-vpn:
	make requirements
	ansible-playbook playbooks/deploy-vpn.yml

deploy-vault:
	make requirements
	ansible-playbook playbooks/deploy-vault.yml

deploy-proxy:
	make requirements
	ansible-playbook playbooks/deploy-proxy.yml \
		--extra-vars CLOUDFLARE_API_TOKEN=$${CLOUDFLARE_API_TOKEN}

deploy-mtproxy:
	make requirements
	ansible-playbook playbooks/deploy-mtproxy.yml

deploy-3x-ui:
	make requirements
	ansible-playbook playbooks/deploy-3x-ui.yml

deploy-lubelog:
	make requirements
	ansible-playbook playbooks/deploy-lubelog.yml \
		--extra-vars "lubelog_db_url=$${LUBELOG_DB_URL}"

3x-ui-metrics-firewall:
	make requirements
	ansible-playbook playbooks/3x-ui-metrics-firewall.yml

deploy-grafana-alloy:
	make requirements
	ansible-playbook playbooks/deploy-grafana-alloy.yml \
		--extra-vars CLOUDFLARE_API_TOKEN=$${CLOUDFLARE_API_TOKEN}

backup-3x-ui:
	make requirements
	ansible-playbook playbooks/backup-3x-ui.yml \
		--extra-vars CLOUDFLARE_R2_API_KEY_ID=$${CLOUDFLARE_R2_API_KEY_ID} \
		--extra-vars CLOUDFLARE_R2_API_ACCESS_SECRET=$${CLOUDFLARE_R2_API_ACCESS_SECRET} \
		--extra-vars CLOUDFLARE_ACCOUNT_ID=$${CLOUDFLARE_ACCOUNT_ID}

restore-3x-ui:
	make requirements
	ansible-playbook playbooks/restore-3x-ui.yml \
		--extra-vars CLOUDFLARE_R2_API_KEY_ID=$${CLOUDFLARE_R2_API_KEY_ID} \
		--extra-vars CLOUDFLARE_R2_API_ACCESS_SECRET=$${CLOUDFLARE_R2_API_ACCESS_SECRET} \
		--extra-vars CLOUDFLARE_ACCOUNT_ID=$${CLOUDFLARE_ACCOUNT_ID} \
		--extra-vars BACKUP_FILENAME=$${BACKUP_FILENAME}
