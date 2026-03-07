# Local Development Environment Setup

Simple, standard Ansible setup for local development environments.

## 🚀 Quick Start

```bash
git clone <repo-url>
cd local-setup
./bootstrap.sh
```

## 📁 Structure

```
local-setup/
├── site.yml              # Main playbook (runs all)
├── playbooks/            # Playbook directory (Ansible standard)
│   ├── system.yml        # System packages (requires sudo)  
│   ├── user.yml          # User config (shell, python, ssh)
│   └── tools.yml         # Development tools (homebrew)
├── vars/main.yml         # Configuration
├── inventory/hosts.yml   # Inventory
├── ansible.cfg           # Ansible config
├── requirements.yml      # Required collections
└── linux/zsh-plugins.sh # Shell plugins
```

## 🎯 What Gets Installed

- **System**: Base packages, build tools, Python 3
- **Shell**: zsh + Oh My Zsh with custom theme
- **Python**: pyenv + Python 3.13.9  
- **Tools**: AWS CLI, Terraform, GitHub CLI, Node.js, Go, etc.
- **SSH**: 4096-bit RSA key generation

## 🔧 Configuration

Edit `vars/main.yml`:

```yaml
python_version: "3.13.9"
zsh_theme: "robbyrussell"

# Tool versions - YOU control when to upgrade
# Format: tool_name: version (null = latest, no pin)
development_tools:
  terraform: "1.5.7"   # tfenv - change this to upgrade
  node: "18"           # node@18 - use "18", "20", "22" for versioned
  awscli: null         # latest, no pin
  gh: null
  # ...
```

## 📖 Usage

```bash
# Full setup (prompts for sudo password)
ansible-playbook site.yml --ask-become-pass

# Individual parts
ansible-playbook playbooks/system.yml --ask-become-pass   # System (sudo required)
ansible-playbook playbooks/user.yml      # User config
ansible-playbook playbooks/tools.yml     # Development tools

# Validate tool versions (check for upgrades)
make validate

# Preview changes
ansible-playbook site.yml --check --diff --ask-become-pass

# Test syntax
ansible-playbook site.yml --syntax-check
```

## ✅ Features

- **Simple**: 3 playbooks, minimal structure
- **Standard**: Follows Ansible best practices
- **Idempotent**: Safe to run multiple times
- **Cross-platform**: Ubuntu/Debian + Fedora/RHEL
- **No duplication**: Single source of truth

## 🛠️ Tool Version Control

- **Pin versions**: Set version in `vars/main.yml` (e.g. `terraform: "1.5.7"`)
- **Upgrade**: Change the version, run setup again
- **Validate**: `make validate` to see installed vs available versions
- **Terraform**: Uses tfenv; set exact version (e.g. `"1.5.7"`)
- **Node**: Use `"18"`, `"20"`, `"22"` for node@18, etc.
- **Others**: Set version to pin (locks current), `null` for latest

## 🆘 Troubleshooting

- **"sudo: a password is required"**: Add `--ask-become-pass` (or `-K`) to prompt for your sudo password
- **Syntax errors**: `ansible-playbook site.yml --syntax-check`
- **Preview changes**: `ansible-playbook site.yml --check --diff --ask-become-pass`  
- **Verbose output**: `ansible-playbook site.yml -v`

## 📋 Requirements

- Linux (Ubuntu/Debian or Fedora/RHEL)
- Internet connection
- sudo access for system setup

Bootstrap script installs Ansible automatically.

## 📜 Legacy Scripts

The `linux/` and `windows/` directories contain the original shell scripts for reference:
- **Recommended**: Use Ansible setup (`./bootstrap.sh` or `make install`)
- **Legacy**: Shell scripts available in `linux/` directory
- **Windows**: PowerShell setup available in `windows/` directory