#!/bin/bash
set -eo pipefail

. $(dirname $0)/shared-lib.sh

downloads="$(dirname $0)/downloads"

#
# User setup
#
# Note: this needs to be executed after base-setup.sh

# TODO make settings configurable
default_shell="zsh"

echo "Running as $USER"
if [[ "$USER" == "root" ]]; then
  echo "Do not run this script as root or using sudo."
  exit 1
fi

echo "Checking shell"
default_shell_path=$(which $default_shell)
if [[ "$SHELL" != "$default_shell_path" ]]; then
  echo "Changing default shell from $SHELL to $default_shell"
  chsh -s $default_shell_path
fi

echo "Installing shell extensions"
if [[ "$default_shell" == "zsh" ]]; then

  if [[ -e "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh is already installed"
  else 
    echo "Installing oh-my-zsh"
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  fi
fi

echo "Setting up SSH"
if [[ -e "$HOME/.ssh" ]]; then
  echo "$HOME/.ssh exists.  Skipping..."
else
  ssh-keygen
fi

echo "Update your keys in GitHub.com"