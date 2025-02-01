requirements:
	ansible-galaxy install -r requirements.yml

infrastructure:
	make requirements
	ansible-playbook -K playbooks/infrastructure.yml

deploy:
	make requirements
	ansible-playbook -K playbooks/infrastructure.yml
