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
	@echo "  validate - Run syntax, lint, state, and tool version checks"
	@echo "  clean    - Clean up logs"

install:
	./bootstrap.sh

check:
	ansible-playbook site.yml --check --diff --ask-become-pass

system:
	@sudo -v
	@privileged_tmp=$$(mktemp -d /tmp/ansible-privileged.XXXXXX); \
	trap 'sudo rm -rf "$$privileged_tmp"' EXIT; \
	sudo env \
		HOME="$$HOME" \
		USER="$${USER:-$$(id -un)}" \
		LOGNAME="$${LOGNAME:-$$(id -un)}" \
		SUDO_USER="$${SUDO_USER:-$${USER:-$$(id -un)}}" \
		ANSIBLE_LOCAL_TEMP="$$privileged_tmp" \
		ANSIBLE_REMOTE_TEMP="$$privileged_tmp" \
		ansible-playbook playbooks/system.yml --extra-vars "system_become=false"

user:
	@sudo -v
	@privileged_tmp=$$(mktemp -d /tmp/ansible-privileged.XXXXXX); \
	trap 'sudo rm -rf "$$privileged_tmp"' EXIT; \
	sudo env \
		HOME="$$HOME" \
		USER="$${USER:-$$(id -un)}" \
		LOGNAME="$${LOGNAME:-$$(id -un)}" \
		SUDO_USER="$${SUDO_USER:-$${USER:-$$(id -un)}}" \
		ANSIBLE_LOCAL_TEMP="$$privileged_tmp" \
		ANSIBLE_REMOTE_TEMP="$$privileged_tmp" \
		ansible-playbook playbooks/user.yml --tags privileged_user --extra-vars "user_privileged_become=false"
	ansible-playbook playbooks/user.yml --skip-tags privileged_user

tools:
	ansible-playbook playbooks/tools.yml

audit:
	ansible-playbook playbooks/tools.yml --tags audit

validate:
	ansible-playbook site.yml --syntax-check
	@if command -v ansible-lint >/dev/null 2>&1; then \
		ansible-lint site.yml playbooks/*.yml; \
	else \
		echo "Skipping ansible-lint (not installed)"; \
	fi
	@if command -v yamllint >/dev/null 2>&1; then \
		yamllint .; \
	else \
		echo "Skipping yamllint (not installed)"; \
	fi
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck bootstrap.sh config/zsh-plugins.sh; \
	else \
		echo "Skipping shellcheck (not installed)"; \
	fi
	@if command -v shfmt >/dev/null 2>&1; then \
		shfmt -d bootstrap.sh config/zsh-plugins.sh; \
	else \
		echo "Skipping shfmt (not installed)"; \
	fi
	ansible-playbook playbooks/validate.yml
	ansible-playbook playbooks/tools.yml --tags validate

clean:
	rm -f ansible.log *.retry
