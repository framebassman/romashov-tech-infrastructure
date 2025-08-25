requirements:
	ansible-galaxy install --role-file requirements.yml

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
