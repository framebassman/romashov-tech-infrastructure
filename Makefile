requirements:
	ansible-galaxy install -r requirements.yml

infrastructure:
	make requirements
	ansible-playbook -K playbooks/infrastructure.yml

deploy-vpn:
	make requirements
	ansible-playbook -K playbooks/deploy-vpn.yml

deploy-vault:
	make requirements
	ansible-playbook -K playbooks/deploy-vault.yml
