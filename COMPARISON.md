# Shell Scripts vs Ansible: Side-by-Side Comparison

## Quick Reference

### Shell Scripts
```bash
sudo ./linux/01-base-setup.sh    # Must run first
./linux/02-user-setup.sh          # Then user setup
./linux/03-tools-setup.sh         # Finally tools
```

### Ansible
```bash
ansible-playbook site.yml         # Run everything once
# OR
sudo ansible-playbook base-setup.yml
ansible-playbook user-setup.yml
ansible-playbook tools-setup.yml
```

## Feature Comparison

| Feature | Shell Scripts | Ansible |
|---------|---------------|---------|
| **Idempotency** | ❌ No | ✅ Yes - safe to re-run |
| **Dry Run** | ❌ No | ✅ Yes - `--check --diff` |
| **Error Handling** | ⚠️ Basic | ✅ Robust with rollback |
| **Dependency Checks** | ⚠️ Manual | ✅ Automatic |
| **State Tracking** | ❌ No | ✅ Built-in |
| **Testing** | ⚠️ Manual tests | ✅ `--syntax-check` |
| **Cross-Platform** | ⚠️ Partial | ✅ Better |
| **Maintainability** | ⚠️ Linear code | ✅ Modular |
| **Verbosity** | ⚠️ Manual logs | ✅ Built-in levels |
| **Learning Curve** | ✅ Easy | ⚠️ Moderate |
| **Dependencies** | ✅ None | ⚠️ Needs Ansible |

## Real-World Scenarios

### Scenario 1: First-Time Setup

**Shell Scripts:**
```bash
# Step 1: Must remember to run as sudo
sudo ./linux/01-base-setup.sh

# Step 2: Switch to regular user
exit  # if in sudo shell
./linux/02-user-setup.sh

# Step 3: Continue as user
./linux/03-tools-setup.sh
```
**Risk:** Easy to miss a step or run in wrong order

**Ansible:**
```bash
# Just run once - all handled automatically
ansible-playbook site.yml
```
**Benefit:** One command, proper privilege handling

---

### Scenario 2: Adding a New Tool

**Shell Scripts:**
```bash
# Edit linux/03-tools-setup.sh
# Add: brew install new-tool
# Hope you get the syntax right
```
**Risk:** Easy to break existing functionality

**Ansible:**
```yaml
# Edit tools-setup.yml
# Add to list:
development_tools:
  - awscli
  - new-tool
# Ansible validates syntax
```
**Benefit:** Declarative, validated

---

### Scenario 3: Re-running Setup

**Shell Scripts:**
```bash
# Re-run base setup
sudo ./linux/01-base-setup.sh  # Might duplicate symlinks
# Re-run user setup
./linux/02-user-setup.sh       # Might reinstall Oh My Zsh
# Re-run tools
./linux/03-tools-setup.sh      # Might reinstall everything
```
**Risk:** Duplicate work, potential errors, wasted time

**Ansible:**
```bash
# Re-run everything - only changes what's needed
ansible-playbook site.yml
```
**Benefit:** Smart, fast, safe

---

### Scenario 4: Testing Before Committing

**Shell Scripts:**
```bash
# No safe way to test
# Must run on actual system
sudo ./linux/01-base-setup.sh  # Prays it works
```
**Risk:** Could break system

**Ansible:**
```bash
# Test without making changes
ansible-playbook site.yml --check --diff
# Validate syntax
ansible-playbook site.yml --syntax-check
# See what will change
ansible-playbook site.yml --list-tasks
```
**Benefit:** Safety first

---

### Scenario 5: Partial Update

**Shell Scripts:**
```bash
# Need to add logic for conditions
if [[ ! -f /usr/bin/terraform ]]; then
    # install
fi
```
**Risk:** Easy to miss edge cases

**Ansible:**
```bash
# Built-in idempotency
ansible-playbook tools-setup.yml  # Only installs what's missing
```
**Benefit:** Handled automatically

---

## Code Comparison

### Installing a Package

**Shell Scripts:**
```bash
# Linux/01-base-setup.sh
echo "Installing git"
if ! command -v git >/dev/null 2>&1; then
    pkgmgr install -y git-all
else
    echo "git already installed"
fi
```
**Lines:** ~6, Manual checks

**Ansible:**
```yaml
# base-setup.yml
- name: Install base utility packages
  package:
    name:
      - curl
      - git
    state: present
```
**Lines:** 5, Automatic checks

---

### Configuration File Changes

**Shell Scripts:**
```bash
# linux/02-user-setup.sh
if ! grep -q "\.zsh-plugins\.sh" "$zshrc_file"; then
    temp_file=$(mktemp)
    added=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        echo "$line" >>"$temp_file"
        if [[ "$line" =~ ^ZSH_THEME= ]] && [[ $added -eq 0 ]]; then
            echo "# Load custom plugin configuration" >>"$temp_file"
            echo "[ -f ~/.zsh-plugins.sh ] && source ~/.zsh-plugins.sh" >>"$temp_file"
            added=1
        fi
    done <"$zshrc_file"
    mv "$temp_file" "$zshrc_file"
fi
```
**Lines:** ~20, Error-prone

**Ansible:**
```yaml
# user-setup.yml
- name: Ensure plugin source line in .zshrc
  lineinfile:
    path: "{{ ansible_env.HOME }}/.zshrc"
    regexp: '\.zsh-plugins\.sh'
    line: '[ -f ~/.zsh-plugins.sh ] && source ~/.zsh-plugins.sh'
    insertafter: '^ZSH_THEME='
    state: present
    backup: yes
```
**Lines:** 8, Safe with backup

---

## When to Use Which?

### Use Shell Scripts When:
✅ Need zero dependencies  
✅ One-time setup only  
✅ Comfortable with bash  
✅ Simple, linear workflow  
✅ Don't need re-runnability

### Use Ansible When:
✅ Setting up multiple machines  
✅ Want idempotency  
✅ Need dry-run capability  
✅ Will maintain/extend this  
✅ Want better error handling  
✅ Need modularity  
✅ Working with a team

## Migration Path

### For New Users
1. Start with Ansible (recommended)
2. Learning curve pays off quickly
3. Better long-term maintainability

### For Existing Users
1. Keep shell scripts as fallback
2. Try Ansible for new setups
3. Gradually migrate if you like it
4. Both work in parallel

## Conclusion

**Ansible is simpler for:**
- Maintenance
- Reliability
- Multiple setups
- Teams

**Shell scripts are simpler for:**
- Quick one-offs
- Zero dependencies
- Bash experts

**Recommendation:** For a development environment setup like this, **Ansible offers significant advantages** with minimal complexity trade-off.

