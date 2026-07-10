#!/bin/bash
# Bootstrap script for fresh system installation
# Detects OS and installs Ansible automatically
# Then runs the full setup

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory (portable)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Function to print colored output
print_info() {
	echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
	print_error "Do not run this script as root!"
	print_info "Run as regular user, script will prompt for sudo when needed"
	exit 1
fi

# Check for Python 3 (required)
if ! command -v python3 &>/dev/null; then
	print_error "Python 3 is required but not installed"
	print_info "Please install Python 3 first:"
	print_info "  Debian/Ubuntu: sudo apt install python3"
	print_info "  Fedora/RHEL: sudo dnf install python3"
	print_info "  Arch: sudo pacman -S python"
	exit 1
fi

# Detect OS and package manager
if [[ -f /etc/os-release ]]; then
	# shellcheck source=/etc/os-release disable=SC1091
	source /etc/os-release

	case "$ID" in
	ubuntu | debian)
		ANSIBLE_INSTALL="sudo apt install -y ansible"
		;;
	fedora | rhel | centos | rocky)
		ANSIBLE_INSTALL="sudo dnf install -y ansible"
		;;
	arch | manjaro)
		ANSIBLE_INSTALL="sudo pacman -S --noconfirm ansible"
		;;
	opensuse*)
		ANSIBLE_INSTALL="sudo zypper install -y ansible"
		;;
	*)
		print_warn "Unsupported distribution: $ID"
		ANSIBLE_INSTALL="pip3 install --user ansible ansible-core"
		;;
	esac

	print_info "Detected OS: $PRETTY_NAME"
else
	print_warn "Cannot detect OS, will try pip install"
	ANSIBLE_INSTALL="pip3 install --user ansible ansible-core"
fi

# Check if Ansible is already installed
if command -v ansible-playbook &>/dev/null; then
	print_info "Ansible is already installed: $(ansible-playbook --version | head -1)"
else
	print_info "Ansible not found, installing..."

	if ! eval "$ANSIBLE_INSTALL"; then
		print_error "Failed to install Ansible via package manager, trying pip..."

		# Try python3 -m pip first (more reliable)
		if python3 -m pip --version &>/dev/null; then
			python3 -m pip install --user ansible ansible-core
		elif command -v pip3 &>/dev/null; then
			pip3 install --user ansible ansible-core
		else
			print_error "pip3 not found! Please install pip first:"
			print_info "  Debian/Ubuntu: sudo apt install python3-pip"
			print_info "  Fedora/RHEL: sudo dnf install python3-pip"
			exit 1
		fi

		# Add user local bin to PATH if needed
		if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
			export PATH="$HOME/.local/bin:$PATH"
			print_info "Added $HOME/.local/bin to PATH for this session"
		fi
	fi

	if ! command -v ansible-playbook &>/dev/null; then
		print_error "Failed to install Ansible. Please install manually and try again."
		exit 1
	fi

	print_info "Ansible installed successfully"
fi

# Verify Ansible is in PATH
if ! command -v ansible-playbook &>/dev/null; then
	print_error "Ansible not found in PATH"
	exit 1
fi

# Check if inventory exists, create if not
if [[ ! -f inventory/hosts.yml ]]; then
	print_info "Creating inventory/hosts.yml..."
	mkdir -p inventory
	cat >inventory/hosts.yml <<'EOF'
---
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
EOF
fi

# Run the playbooks
print_info "Starting full setup..."
print_info "This will install: base packages, user config, and development tools"
echo ""

# Ask for confirmation unless running in CI
if [[ -z "${CI:-}" ]]; then
	read -p "Continue with setup? [y/N] " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		print_info "Setup cancelled by user"
		exit 0
	fi
fi

# Collect and validate sudo before Ansible starts. Some systems customize the
# sudo/PAM prompt in a way Ansible cannot recognize, so bootstrap runs the
# privileged phases with sudo outside of Ansible's become prompt handling.
# Authenticate on the real TTY (sudo -v) and reuse the credential cache so the
# password is never stored in a shell variable or piped to sudo -S.
cleanup_sudo_cache() {
	sudo -K 2>/dev/null || true
}
trap cleanup_sudo_cache EXIT

ensure_sudo() {
	if sudo -n true 2>/dev/null; then
		return 0
	fi

	if [[ -n "${CI:-}" ]]; then
		print_error "CI requires passwordless sudo for privileged setup phases"
		return 1
	fi

	print_info "Sudo authentication required..."
	sudo -v
}

run_privileged() {
	# Use a dedicated Ansible temp dir so privileged runs do not leave
	# root-owned files under ./.ansible/tmp for later user-level playbooks.
	local privileged_tmp status
	privileged_tmp=$(mktemp -d /tmp/ansible-privileged.XXXXXX)
	sudo env \
		HOME="$HOME" \
		USER="${USER:-$(id -un)}" \
		LOGNAME="${LOGNAME:-$(id -un)}" \
		SUDO_USER="${SUDO_USER:-${USER:-$(id -un)}}" \
		ANSIBLE_LOCAL_TEMP="$privileged_tmp" \
		ANSIBLE_REMOTE_TEMP="$privileged_tmp" \
		"$@"
	status=$?
	sudo rm -rf "$privileged_tmp" || true
	return "$status"
}

print_info "Validating sudo access..."
if ! ensure_sudo; then
	print_error "Unable to validate sudo access"
	exit 1
fi

# Run privileged phases as root without Ansible become, then run user phases
# as the current user.
print_info "Running system setup..."
if run_privileged ansible-playbook playbooks/system.yml --extra-vars "system_become=false"; then
	print_info "Running privileged user setup..."
else
	print_error "System setup failed! See errors above."
	exit 1
fi

if run_privileged ansible-playbook playbooks/user.yml --tags privileged_user --extra-vars "user_privileged_become=false"; then
	print_info "Running user configuration..."
else
	print_error "Privileged user setup failed! See errors above."
	exit 1
fi

if ansible-playbook playbooks/user.yml --skip-tags privileged_user && ansible-playbook playbooks/tools.yml; then
	print_info ""
	print_info "Setup complete!"
	print_info ""
	print_info "Next steps:"
	print_info "  - Restart your terminal or run: source ~/.zshrc"
	print_info "  - Add your SSH key to GitHub"
	print_info "  - Verify tools: terraform --version, aws --version, gh --version"
	print_info ""
else
	print_error "Setup failed! See errors above."
	exit 1
fi
