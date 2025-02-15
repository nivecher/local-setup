#!/bin/bash
# Enable strict error handling
set -eo pipefail

# This script performs base system setup for Linux environments
# It handles:
# - Package repository updates
# - Installation of common utilities and development tools
# - Python environment configuration
# - Desktop environment setup (MATE)
#
# Must be run with root/sudo privileges

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
. "$SCRIPT_DIR/shared-lib.sh"

# TODO log / check linux distribution

# TODO check effective user (must be run w/ sudo)

# Verify the Linux distribution being used
echo "Checking distribution"
cat /etc/os-release

# Ensure script is run with root privileges
echo "Checking user"
if [[ "$USER" != "root" ]]; then
	echo "Script must be run as root or using sudo!"
	exit 1
fi

# Update system package repositories
echo "Updating packages"
pkgmgr update -y

echo "Installing utility packages"
# Basic system utilities:
# - curl: Command line tool for transferring data
# - wget: Alternative tool for downloading files
# - zsh: Enhanced shell with better features than bash
# - mate: Lightweight desktop environment
# - tree: Directory listing in tree format
#
pkgmgr install -y curl wget zsh mate tree

echo "Installing development packages"
# Core development tools:
# - git-all: Complete git installation with all components
# - python3: Python programming language interpreter
# - python3-pip: Python package installer
# - python3-virtualenv: Python virtual environment creator
pkgmgr install -y git-all python3 python3-pip python3-virtualenv

echo "Python setup"
# Create symbolic links for python and pip if they don't exist
# This ensures 'python' and 'pip' commands work without version numbers
if [[ ! -f "/usr/bin/python" ]]; then
	echo "Creating link to python3"
	ln -s /usr/bin/python3 /usr/bin/python
fi
if [[ ! -f "/usr/bin/pip" ]]; then
	echo "Creating link to pip3"
	ln -s /usr/bin/pip3 /usr/bin/pip
fi

echo "NOTE: next run: $SCRIPT_DIR/02-user-setup.sh"

echo "Done"
