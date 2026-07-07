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
ansible-playbook site.yml

# Individual parts
ansible-playbook playbooks/system.yml   # System (sudo required)
ansible-playbook playbooks/user.yml      # User config
ansible-playbook playbooks/tools.yml     # Development tools

# Validate tool versions (check for upgrades)
make validate

# Preview changes
ansible-playbook site.yml --check --diff

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

- **"sudo: a password is required"**: This repo config prompts for sudo by default. If running outside this config, add `--ask-become-pass` (or `-K`)
- **Syntax errors**: `ansible-playbook site.yml --syntax-check`
- **Preview changes**: `ansible-playbook site.yml --check --diff`
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
