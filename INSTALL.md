# Installation Guide

Complete installation guide for local-setup on fresh systems.

## Quick Start (One Command)

**For most systems:**

```bash
# Clone the repository
git clone https://github.com/yourusername/local-setup.git
cd local-setup

# Run bootstrap (handles everything)
./bootstrap.sh
```

That's it! The bootstrap script will:
1. Detect your OS
2. Install Ansible
3. Configure your entire development environment

## Prerequisites

### Minimum Requirements

- **Linux** distribution (Ubuntu, Debian, Fedora, RHEL, CentOS, Rocky, Arch, openSUSE)
- **Python 3.6+** (usually pre-installed)
- **Network connection** for downloading packages
- **Sudo/root access** for system package installation
- **Git** for cloning the repository

### Bare Systems (Python not installed)

If Python 3 is not installed, you need to install it first:

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y python3 python3-pip git
```

**Fedora/RHEL/CentOS/Rocky:**
```bash
sudo dnf install -y python3 python3-pip git
```

**Arch:**
```bash
sudo pacman -S python python-pip git
```

**openSUSE:**
```bash
sudo zypper install -y python3 python3-pip git
```

Then proceed with the bootstrap:

```bash
./bootstrap.sh
```

## Installation Methods

### Method 1: Bootstrap Script (Recommended) ⭐

The bootstrap script handles everything automatically:

```bash
./bootstrap.sh
```

**Features:**
- Auto-detects your OS
- Installs Ansible (package manager or pip)
- Runs complete setup
- Idempotent (safe to re-run)
- Interactive confirmation

### Method 2: Manual Ansible Setup

If Ansible is already installed:

```bash
# Install Ansible manually first (if needed)
# See "Ansible Installation" section below

# Then run setup
ansible-playbook site.yml
```

### Method 3: Ansible Bootstrap Playbook

If you already have Ansible but want it updated:

```bash
# First, run bootstrap to ensure latest Ansible
sudo ansible-playbook bootstrap.yml

# Then run main setup
ansible-playbook site.yml
```

### Method 4: Legacy Shell Scripts

For systems without Python 3 or special requirements:

```bash
sudo ./linux/01-base-setup.sh
./linux/02-user-setup.sh
./linux/03-tools-setup.sh
```

**Warning:** Shell scripts are not idempotent. Only use if Ansible setup fails.

## Ansible Installation

If you need to install Ansible manually:

### Via Package Manager (Recommended)

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install -y ansible
```

**Fedora/RHEL/CentOS/Rocky:**
```bash
sudo dnf install -y ansible
```

**Arch:**
```bash
sudo pacman -S ansible
```

**openSUSE:**
```bash
sudo zypper install -y ansible
```

### Via pip (Universal)

If your package manager doesn't have Ansible:

```bash
# Install pip if needed
sudo apt install python3-pip  # Debian/Ubuntu
sudo dnf install python3-pip  # Fedora/RHEL

# Install Ansible
pip3 install --user ansible

# Add local bin to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify installation:
```bash
ansible-playbook --version
```

## What Gets Installed

### Base System Packages
- curl, wget, git, tree, gawk
- Python 3 with pip and virtualenv
- zsh shell

### User Configuration
- Oh My Zsh framework
- Zsh plugins (git, aws, docker, kubectl, terraform)
- Homebrew for Linux
- SSH key generation

### Development Tools (via Homebrew)
- AWS CLI
- Terraform
- Terragrunt
- GitHub CLI (gh)
- pre-commit
- jq (JSON processor)
- yq (YAML processor)
- shfmt (Shell formatter)
- shellcheck (Shell linter)

## Post-Installation

After installation completes:

1. **Restart terminal or source configuration:**
   ```bash
   source ~/.zshrc
   ```

2. **Verify tools:**
   ```bash
   terraform --version
   aws --version
   gh --version
   ```

3. **Add SSH key to GitHub:**
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
   Copy the output and add it to GitHub: Settings → SSH and GPG keys

4. **Test Homebrew:**
   ```bash
   brew --version
   ```

## Troubleshooting

### "Ansible not found in PATH"

If bootstrap completes but Ansible isn't found:

```bash
# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Verify
which ansible-playbook
```

### "Python 3 required"

Install Python 3 first (see Prerequisites section above).

### "Permission denied"

Make sure bootstrap script is executable:

```bash
chmod +x bootstrap.sh
```

### "Failed to install Ansible"

Try manual installation (see "Ansible Installation" section).

### "Homebrew not working"

Ensure Homebrew completed installation:

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Add to `~/.zshrc` if needed.

### Re-run Setup

All playbooks are idempotent - safe to re-run:

```bash
./bootstrap.sh
# OR
ansible-playbook site.yml
```

## Advanced Usage

### Dry Run (Preview Changes)

```bash
ansible-playbook site.yml --check --diff
```

### Run Specific Playbooks

```bash
# Just system packages
sudo ansible-playbook base-setup.yml

# Just user config
ansible-playbook user-setup.yml

# Just dev tools
ansible-playbook tools-setup.yml
```

### Customize Installation

Edit `base-setup.yml`, `user-setup.yml`, or `tools-setup.yml` to modify what gets installed.

For tools, edit the `development_tools` list in `tools-setup.yml`:

```yaml
development_tools:
  - awscli
  - terraform
  - your-tool-here
```

### Skip Confirmation (CI/CD)

```bash
CI=1 ./bootstrap.sh
```

## Verification

After installation, verify everything works:

```bash
# Check zsh is default shell
echo $SHELL

# Test development tools
terraform --version
aws --version
gh auth status

# Test jq
echo '{"test": true}' | jq

# Test yq
echo "test: true" | yq eval '.test' -

# Verify Homebrew
brew list

# Check Oh My Zsh plugins
cat ~/.zshrc | grep plugins
```

## Uninstall

To remove installed tools:

```bash
# Remove Homebrew packages
brew uninstall terraform awscli terragrunt gh jq yq shfmt shellcheck pre-commit

# Remove Oh My Zsh
rm -rf ~/.oh-my-zsh

# Remove Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Restore default shell
chsh -s /bin/bash
```

**Note:** System packages remain installed (can be removed via package manager if desired).

## Platform-Specific Notes

### WSL (Windows Subsystem for Linux)

Works great! Use Ubuntu/Fedora/other Linux distro as recommended.

### Docker Containers

Add `--privileged` if using containers:

```bash
docker run --privileged -it ubuntu:latest bash
```

### Cloud Instances

Works on AWS EC2, Azure, GCP VMs, etc. Just clone and run bootstrap.

### CI/CD Systems

Use `CI=1` flag for non-interactive mode:

```bash
CI=1 ./bootstrap.sh
```

## Getting Help

- Check [README.md](README.md) for overview
- Read [README-ANSIBLE.md](README-ANSIBLE.md) for Ansible details
- Review [COMPARISON.md](COMPARISON.md) for shell vs Ansible comparison
- Search existing issues on GitHub
- Create new issue with system details and error output

## Contributing

Found a bug or have an improvement? Pull requests welcome!

Test your changes:

```bash
# Syntax check
ansible-playbook site.yml --syntax-check

# Dry run
ansible-playbook site.yml --check --diff
```

