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

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# shellcheck source=./shared-lib.sh disable=SC1091
. "$SCRIPT_DIR/shared-lib.sh"

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
	sudo chsh "$(id -un)" --shell "$default_shell_path"
fi

# Install and configure shell extensions
echo "Installing shell extensions"
if [[ "$default_shell" == "zsh" ]]; then

	if [[ -e "$HOME/.oh-my-zsh" ]]; then
		echo "Oh My Zsh is already installed"
	else
		echo "Installing oh-my-zsh"
		sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
	fi
fi

echo "Installing Homebrew"
if [[ -e "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
	echo "Homebrew is already installed"
	echo "Updating Homebrew"
	/home/linuxbrew/.linuxbrew/bin/brew update
else
	echo "Installing Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo '# Set PATH, MANPATH, etc., for Homebrew.' >>"$HOME"/.zprofile
	# Add Homebrew to PATH
	echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >>"$HOME/.zshrc"
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

echo "Setting up SSH"
if [[ -e "$HOME/.ssh" ]]; then
	echo "$HOME/.ssh exists.  Skipping..."
else
	ssh-keygen
fi

# Reminder for manual GitHub setup
echo "Update your keys in GitHub.com"

echo "NOTE: next run: $(dirname "$0")/03-tools-setup.sh"

echo "Done"
