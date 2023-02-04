start:
	ansible-galaxy install -r requirements.yml
	ansible-playbook -K playbooks/server.yml
