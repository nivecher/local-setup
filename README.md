# local-setup

Local setup for development for various platforms

## Quick Start 🚀

Get started in 2 minutes:

```bash
git clone <repo-url>
cd local-setup
./bootstrap.sh
```

That's it! See [QUICKSTART.md](QUICKSTART.md) for details.

The bootstrap script automatically:
1. Detects your OS (Debian/Ubuntu, Fedora/RHEL, Arch, etc.)
2. Installs Ansible if needed
3. Installs all base packages and utilities (including gawk)
4. Configures your shell (zsh + Oh My Zsh)
5. Installs development tools

## Manual Setup Options

### Option 1: Ansible (Recommended) ⭐

If Ansible is already installed:

```bash
# Run everything
ansible-playbook site.yml

# Or run individual parts
sudo ansible-playbook base-setup.yml
ansible-playbook user-setup.yml
ansible-playbook tools-setup.yml

# Test without making changes
ansible-playbook site.yml --check --diff
```

**Why Ansible?** Idempotent, testable with `--check`, better error handling, easier to extend.

### Option 2: Shell Scripts (Legacy)

Original bash-based setup. Still works but less robust.

```bash
# Base Setup - Update O/S packages, setup languages, etc.
sudo ./linux/01-base-setup.sh

# User Setup - User specific setup (executed as user, not system)
./linux/02-user-setup.sh

# Tools Setup - Install / update developer tools
./linux/03-tools-setup.sh
```

**Warning:** Scripts are not idempotent - re-running may cause issues.

## What Gets Installed

### Base System
- curl, wget, git, tree, gawk
- Python 3 with pip and virtualenv
- zsh shell

### User Configuration
- Oh My Zsh with plugins (git, aws, docker, kubectl, terraform)
- Homebrew for Linux
- SSH key generation

### Development Tools
- AWS CLI
- Terraform & Terragrunt
- GitHub CLI
- pre-commit
- jq, yq
- shfmt, shellcheck

## Platform Support

- ✅ Linux (Debian, Ubuntu, Fedora, RHEL, CentOS, Rocky, Arch, Manjaro, openSUSE)
- ⚠️ Windows (PowerShell script available in `windows/`)

## Documentation

- **[Quick Start](QUICKSTART.md)** - Get started in 2 minutes
- **[Installation Guide](INSTALL.md)** - Complete instructions with troubleshooting
- [Ansible Setup Guide](README-ANSIBLE.md) - Detailed Ansible usage
- [Side-by-Side Comparison](COMPARISON.md) - Shell Scripts vs Ansible
- [Linux Scripts](linux/) - Original shell scripts
- [Windows Setup](windows/) - PowerShell scripts
