requirements:
	ansible-galaxy install -r requirements.yml

infrastructure:
	make requirements
	ansible-playbook playbooks/infrastructure.yml

deploy-vpn:
	make requirements
	ansible-playbook playbooks/deploy-vpn.yml

deploy-vault:
	make requirements
	ansible-playbook playbooks/deploy-vault.yml

deploy-proxy:
	make requirements
	ansible-playbook playbooks/deploy-proxy.yml

deploy-mtproxy:
	make requirements
	ansible-playbook playbooks/deploy-mtproxy.yml

deploy-3x-ui:
	make requirements
	ansible-playbook playbooks/deploy-3x-ui.yml

deploy-monitoring:
	make requirements
	ansible-playbook playbooks/deploy-monitoring.yml

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
		$(if $(BACKUP_FILENAME),--extra-vars backup_filename=$(BACKUP_FILENAME),)
