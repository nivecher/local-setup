# Quick Start Guide

Get up and running in 2 minutes!

## The Simple Way

```bash
git clone <your-repo-url>
cd local-setup
./bootstrap.sh
```

That's it! Everything else is automatic.

## What You Need

1. **Linux** (Ubuntu, Fedora, Arch, etc.)
2. **Python 3** (usually pre-installed)
3. **Sudo access** (for system packages)
4. **Git** (to clone the repo)

## What Happens

The bootstrap script will:

1. ✅ Detect your operating system
2. ✅ Install Ansible automatically
3. ✅ Install base system packages (curl, git, zsh, etc.)
4. ✅ Configure your shell (Oh My Zsh + plugins)
5. ✅ Install Homebrew for Linux
6. ✅ Install development tools (terraform, aws cli, gh, etc.)

## After Installation

```bash
# Reload your shell
source ~/.zshrc

# Verify tools
terraform --version
aws --version
gh --version
```

## Troubleshooting

**"Python 3 not found"**
```bash
# Ubuntu/Debian
sudo apt install python3

# Fedora/RHEL
sudo dnf install python3

# Then run bootstrap again
./bootstrap.sh
```

**"Permission denied"**
```bash
chmod +x bootstrap.sh
```

**"Ansible failed to install"**

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

## Need More Help?

- Full guide: [INSTALL.md](INSTALL.md)
- Ansible details: [README-ANSIBLE.md](README-ANSIBLE.md)
- Comparison: [COMPARISON.md](COMPARISON.md)

## Re-running Setup

**Safe to re-run anytime!** The setup is idempotent:

```bash
./bootstrap.sh
```

Only missing packages or updated configs will change.

