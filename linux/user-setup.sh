#!/bin/bash
#
# User Setup Script
#
# Purpose:
#   Configures user-specific settings and tools including:
#   - Default shell configuration
#   - Shell extensions (Oh My Zsh)
#   - SSH key generation
#
# Requirements:
#   - Must be run as a normal user (not root)
#   - base-setup.sh must be run first
#   - Internet connection for Oh My Zsh installation
#

# Enable strict error handling
set -eo pipefail

# Import shared utilities
. $(dirname $0)/shared-lib.sh

# Directory for downloaded files
downloads="$(dirname $0)/downloads"

#
# User Configuration Settings
#

# Default shell to use (TODO: make this configurable via environment variable)
default_shell="zsh"

# Verify script is not run as root
echo "Running as $USER"
if [[ "$USER" == "root" ]]; then
  echo "Do not run this script as root or using sudo."
  exit 1
fi

# Change default shell if necessary
echo "Checking shell"
default_shell_path=$(which $default_shell)
if [[ "$SHELL" != "$default_shell_path" ]]; then
  echo "Changing default shell from $SHELL to $default_shell"
  chsh -s $default_shell_path
fi

# Install and configure shell extensions
echo "Installing shell extensions"
if [[ "$default_shell" == "zsh" ]]; then
  # Install Oh My Zsh if not already present
  if [[ -e "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh is already installed"
  else
    echo "Installing oh-my-zsh"
    # Download and execute Oh My Zsh installer
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  fi
fi

# Set up SSH keys if not already present
echo "Setting up SSH"
if [[ -e "$HOME/.ssh" ]]; then
  echo "$HOME/.ssh exists.  Skipping..."
else
  # Generate new SSH key pair
  ssh-keygen
fi

# Reminder for manual GitHub setup
echo "Update your keys in GitHub.com"
