#!/bin/bash

# Idempotency Test Script
# This script runs the playbooks multiple times to ensure they are idempotent

set -e

echo "🔄 Testing Ansible Playbook Idempotency"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run playbook and check for changes
test_idempotency() {
    local playbook=$1
    local description=$2
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "Playbook: $playbook"
    
    # First run - may have changes
    echo "  → First run (may have changes)..."
    ansible-playbook "$playbook" --check > /tmp/first_run.log 2>&1
    
    # Second run - should be idempotent (no changes)
    echo "  → Second run (should be idempotent)..."
    ansible-playbook "$playbook" --check > /tmp/second_run.log 2>&1
    
    # Check if second run shows any changes
    if grep -q "changed=0" /tmp/second_run.log; then
        echo -e "  ✅ ${GREEN}PASS: Playbook is idempotent${NC}"
        return 0
    else
        echo -e "  ❌ ${RED}FAIL: Playbook is not idempotent${NC}"
        echo "  Changes detected on second run:"
        grep "changed=" /tmp/second_run.log || true
        return 1
    fi
}

# Test syntax first
echo -e "${YELLOW}Checking syntax...${NC}"
if ansible-playbook site.yml --syntax-check > /dev/null 2>&1; then
    echo -e "✅ ${GREEN}Syntax check passed${NC}"
else
    echo -e "❌ ${RED}Syntax check failed${NC}"
    exit 1
fi

# Test individual playbooks
test_idempotency "base-setup.yml" "Base System Setup"
test_idempotency "user-setup.yml" "User Configuration"
test_idempotency "tools-setup.yml" "Development Tools"

# Test full site playbook
test_idempotency "site.yml" "Complete Setup"

echo -e "\n${GREEN}🎉 Idempotency testing complete!${NC}"
echo -e "${YELLOW}Note: This was run in check mode. For full testing, run without --check${NC}"

# Cleanup
rm -f /tmp/first_run.log /tmp/second_run.log
