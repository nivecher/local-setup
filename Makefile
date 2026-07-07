# Local Development Setup

.PHONY: help install check system user tools audit validate clean

help:
	@echo "Local Development Setup"
	@echo "======================"
	@echo "  install  - Full setup"
	@echo "  check    - Preview changes"
	@echo "  system   - System setup only"
	@echo "  user     - User config only"
	@echo "  tools    - Development tools only"
	@echo "  audit    - Audit tool versions (installed vs outdated)"
	@echo "  validate - Check if tool upgrades are available"
	@echo "  clean    - Clean up logs"

install:
	ansible-playbook site.yml --ask-become-pass

check:
	ansible-playbook site.yml --check --diff --ask-become-pass

system:
	ansible-playbook playbooks/system.yml --ask-become-pass

user:
	ansible-playbook playbooks/user.yml

tools:
	ansible-playbook playbooks/tools.yml

audit:
	ansible-playbook playbooks/tools.yml --tags audit

validate:
	ansible-playbook playbooks/tools.yml --tags validate

clean:
	rm -f ansible.log *.retry
