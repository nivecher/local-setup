#!/bin/bash

# TODO log / check linux distribution

# TODO check effective user (must be run w/ sudo)

echo "Checking user"
if [[ "$USER" != "root" ]]; then
  echo "Script must be run as root or using sudo!"
  exit 1
fi

# Update packages
echo "Updating packages"
apt update -y

echo "Installing packages"
apt install -y zsh git-all curl wget

# TODO echo "Python Setup"


echo "Done"

