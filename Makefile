requirements:
	ansible-galaxy install --role-file ansible/requirements.yml

infrastructure:
	make requirements
	cd ansible && \
		ansible-playbook --roles-path ansible playbooks/infrastructure.yml

deploy-vpn:
	make requirements
	cd ansible && \
		ansible-playbook playbooks/deploy-vpn.yml

deploy-vault:
	make requirements
	cd ansible && \
		ansible-playbook playbooks/deploy-vault.yml

deploy-proxy:
	make requirements
	cd ansible && \
		ansible-playbook playbooks/deploy-proxy.yml
