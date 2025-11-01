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
# Functions
#

# Setup Oh My Zsh plugins from a separate configuration file
# Copies the plugin config file to home directory
# Arguments:
#   $1 - Path to plugins configuration file in repo
setup_zsh_plugins() {
	local repo_plugins_file="$1"
	local home_plugins_file="$HOME/.zsh-plugins.sh"

	if [[ ! -f "$repo_plugins_file" ]]; then
		log "WARN" "Plugins configuration file not found: $repo_plugins_file"
		return 0
	fi

	# Copy plugins file to home directory
	log "INFO" "Copying plugin configuration to $home_plugins_file"
	cp "$repo_plugins_file" "$home_plugins_file"
}

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

# Ensure zsh is installed before changing default shell
echo "Checking shell"
if ! command -v $default_shell >/dev/null 2>&1; then
	echo "$default_shell is not installed. Installing $default_shell..."
	pkgmgr install -y $default_shell
fi

# Change default shell if necessary
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

	# Setup Oh My Zsh plugins from configuration file
	plugins_config="$SCRIPT_DIR/zsh-plugins.sh"
	if [[ -f "$plugins_config" ]]; then
		echo "Setting up Oh My Zsh plugins"
		setup_zsh_plugins "$plugins_config"
		
		# Add source line to .zshrc if not already present (right after ZSH_THEME)
		zshrc_file="$HOME/.zshrc"
		if [[ -f "$zshrc_file" ]] && ! grep -q "\.zsh-plugins\.sh" "$zshrc_file"; then
			temp_file=$(mktemp)
			added=0
			while IFS= read -r line || [[ -n "$line" ]]; do
				echo "$line" >>"$temp_file"
				# Add source line right after ZSH_THEME
				if [[ "$line" =~ ^ZSH_THEME= ]] && [[ $added -eq 0 ]]; then
					echo "# Load custom plugin configuration" >>"$temp_file"
					echo "[ -f ~/.zsh-plugins.sh ] && source ~/.zsh-plugins.sh" >>"$temp_file"
					added=1
				fi
			done <"$zshrc_file"
			if [[ $added -eq 0 ]]; then
				# Append if ZSH_THEME not found
				echo "" >>"$temp_file"
				echo "# Load custom plugin configuration" >>"$temp_file"
				echo "[ -f ~/.zsh-plugins.sh ] && source ~/.zsh-plugins.sh" >>"$temp_file"
			fi
			mv "$temp_file" "$zshrc_file"
		fi
	else
		log "WARN" "Plugins configuration file not found: $plugins_config"
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
	
	# Source .zshrc if running in zsh to apply Homebrew changes
	if [[ -n "$ZSH_VERSION" ]] && [[ -f "$HOME/.zshrc" ]]; then
		log "INFO" "Sourcing .zshrc to apply Homebrew configuration"
		# shellcheck source=~/.zshrc disable=SC1090
		source "$HOME/.zshrc" 2>/dev/null || true
	fi
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
