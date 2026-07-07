# Local Setup

Ansible setup for a fresh Linux development instance.

## Fresh Linux Setup

Install the minimum packages needed to clone and run this repo:

```bash
sudo apt update && sudo apt install -y git python3
git clone <repo-url>
cd local-setup
./bootstrap.sh
```

For Fedora/RHEL:

```bash
sudo dnf install -y git python3
git clone <repo-url>
cd local-setup
./bootstrap.sh
```

`bootstrap.sh` installs Ansible if needed, then runs the full setup. Run it as
your normal user, not with `sudo`; it will prompt when system changes need
sudo.

## Optional Git Config

To configure global git identity and defaults without committing personal values:

```bash
cp config/git.yml.example config/git.yml
vi config/git.yml
./bootstrap.sh
```

`config/git.yml` is ignored by git. Use any global git config key:

```yaml
git_config:
  user.name: "Your Name"
  user.email: "you@example.com"
  init.defaultBranch: main
  pull.rebase: "false"
```

## What It Installs

- Base packages: `curl`, `wget`, `git`, `tree`, `gawk`, `zsh`
- Ruby: RubyGems and headers needed by repo tooling such as pre-commit hooks
- Shell: zsh, Oh My Zsh, and plugins from `config/zsh-plugins.sh`
- Python: pyenv and the Python version in `vars/main.yml`
- Tools: AWS CLI, Terraform, Terragrunt, GitHub CLI, jq, yq, shfmt,
  shellcheck, Node, Go, and pre-commit based on `vars/main.yml`
- SSH: `~/.ssh/id_rsa` if no key exists

## Configuration

Edit `vars/main.yml` for shared setup choices:

```yaml
python_version: "3.13.9"
default_shell: zsh
zsh_theme: "robbyrussell"

development_tools:
  terraform: "1.14.5"
  terragrunt: "0.99.2"
  node: null
  go: null
```

Use `null` for the current Homebrew formula. Terraform is installed through
`tfenv`, and Terragrunt is installed from its pinned GitHub release.

## Common Commands

```bash
make install    # full setup
make check      # preview changes
make system     # system packages only
make user       # shell, pyenv, ssh, optional git config
make tools      # development tools only
make validate   # show installed tool versions
```

## Repo Layout

```text
.
|-- bootstrap.sh
|-- site.yml
|-- playbooks/
|   |-- system.yml
|   |-- user.yml
|   `-- tools.yml
|-- vars/main.yml
|-- config/
|   |-- git.yml.example
|   `-- zsh-plugins.sh
`-- inventory/hosts.yml
```

## Troubleshooting

- If sudo fails, run `make install` or
  `ansible-playbook site.yml --ask-become-pass`.
- If syntax looks wrong, run `ansible-playbook site.yml --syntax-check`.
- After setup, restart your terminal or run `source ~/.zshrc`.
