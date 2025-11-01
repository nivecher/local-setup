# Ansible Setup Alternative

This directory now includes an **Ansible-based setup** as a more robust alternative to the shell scripts.

## Why Ansible?

### Current Shell Script Approach
- ❌ No idempotency (re-running can cause issues)
- ❌ Hard to test and modify
- ❌ No dry-run capability
- ❌ Manual dependency tracking
- ❌ Fragile error handling

### Ansible Benefits
- ✅ **Idempotent**: Safe to run multiple times
- ✅ **Declarative**: Describes desired state, not steps
- ✅ **Dry-run**: Test with `--check` flag
- ✅ **Tagged**: Run specific parts only
- ✅ **Modular**: Better organization
- ✅ **OS-agnostic**: Easier to support multiple distros
- ✅ **Better error handling**: Built-in retry and notification

## One-Command Bootstrap (Recommended)

**For fresh systems** - The bootstrap script automatically:
1. Detects your OS (Ubuntu/Debian, Fedora/RHEL, Arch, etc.)
2. Installs Ansible via your package manager or pip
3. Runs the complete setup

```bash
# Clone the repo
git clone <repo-url>
cd local-setup

# Run bootstrap (one command does everything!)
./bootstrap.sh
```

**That's it!** No manual Ansible installation required.

## Manual Setup (If Bootstrap Doesn't Work)

### Prerequisites

If you need to install Ansible manually:

```bash
# On Debian/Ubuntu
sudo apt install ansible

# On Fedora/RHEL/CentOS
sudo dnf install ansible

# On Arch/Manjaro
sudo pacman -S ansible

# Or via pip (works on all systems)
pip3 install ansible
```

### Usage

### Run Everything
```bash
ansible-playbook site.yml
```

### Run Specific Parts
```bash
# Base system setup only (requires sudo)
sudo ansible-playbook base-setup.yml

# User configuration only
ansible-playbook user-setup.yml

# Development tools only
ansible-playbook tools-setup.yml
```

### Dry Run (Safe Testing)
```bash
# See what would change without making changes
ansible-playbook site.yml --check --diff
```

### Run Specific Tools
```bash
# Install only terraform and awscli
ansible-playbook tools-setup.yml --extra-vars "tools=['terraform','awscli']"
```

## Playbook Structure

```
site.yml              # Main orchestrator (imports all)
├── base-setup.yml    # System packages, python setup (sudo)
├── user-setup.yml    # Shell config, Oh My Zsh, Homebrew, SSH
└── tools-setup.yml   # Developer tools via Homebrew

ansible.cfg          # Ansible configuration
requirements.yml     # Optional: external roles/collections
```

## Migration Notes

This Ansible setup replicates the functionality of:
- `linux/01-base-setup.sh` → `base-setup.yml`
- `linux/02-user-setup.sh` → `user-setup.yml`
- `linux/03-tools-setup.sh` → `tools-setup.yml`

**Key differences:**
1. All playbooks are idempotent (safe to re-run)
2. Better error handling and rollback capability
3. Easier to extend with new tools
4. Works cross-platform with minimal changes
5. No need for manual `shared-lib.sh` - Ansible handles this

## Customization

### Add a new tool to tools-setup.yml:
```yaml
development_tools:
  - awscli
  - terraform
  - your-new-tool  # Add here
```

### Change default shell:
```yaml
vars:
  default_shell: fish  # or bash, zsh, etc.
```

## Advanced Usage

### With Tags
```bash
# Only run Homebrew-related tasks
ansible-playbook user-setup.yml --tags homebrew

# Skip shell configuration
ansible-playbook user-setup.yml --skip-tags shell
```

### Increase Verbosity
```bash
# See detailed output
ansible-playbook site.yml -v       # Verbose
ansible-playbook site.yml -vv      # More verbose
ansible-playbook site.yml -vvv     # Debug level
```

## Comparing Approaches

| Feature | Shell Scripts | Ansible |
|---------|--------------|---------|
| Idempotent | ❌ No | ✅ Yes |
| Testable | ⚠️ Manual | ✅ `--check` |
| Modular | ⚠️ Limited | ✅ Excellent |
| Error Handling | ⚠️ Basic | ✅ Robust |
| Cross-Platform | ⚠️ Partial | ✅ Excellent |
| Learning Curve | ✅ Easy | ⚠️ Moderate |
| Native Tooling | ✅ Bash | ⚠️ Install req'd |

## Recommendation

**Use Ansible if:**
- You need reliable, repeatable setups
- You want to maintain this long-term
- You plan to add more tools/configs
- You work on multiple machines/environments

**Keep shell scripts if:**
- This is a one-time setup
- You want zero dependencies
- You prefer simplicity over features

## Need Help?

```bash
# Validate playbook syntax
ansible-playbook site.yml --syntax-check

# List all tasks that would run
ansible-playbook site.yml --list-tasks

# See which hosts would be affected
ansible-playbook site.yml --list-hosts
```

