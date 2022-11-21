#!/bin/bash

# TODO log / check linux distribution

# TODO check effective user (must be run w/ sudo)

function pkgmgr() {

  dist=$(cat /etc/os-release | egrep "^ID=" | awk -F= '{print $2}' | tr -d "\"")
  if [[ "$dist" == "ubuntu" ]] || [[ "$dist" == "debian" ]]; then
    pm="apt"
  elif [[ "$dist" == "centos" ]]; then
    pm="dnf"
  else
    echo "Unsupported distribution: $dist"
    echo "Exiting..."
    exit 1
  fi
  eval $pm $@
}

# Main

echo "Checking distribution"
echo $(cat /etc/os-release)

echo "Checking user"
if [[ "$USER" != "root" ]]; then
  echo "Script must be run as root or using sudo!"
  exit 1
fi

# Update packages
echo "Updating packages"
pkgmgr update -y

echo "Installing utility packages"
pkgmgr install -y curl wget zsh mate tree

echo "Installing development packages"
pkgmgr install -y git-all python3 python3-pip python3-virtualenv

echo "Python setup"
if [[ ! -f "/usr/bin/python" ]]; then
  echo "Creating link to python3"
  ln -s /usr/bin/python3 /usr/bin/python
fi
if [[ ! -f "/usr/bin/pip" ]]; then
  echo "Creating link to pip3"
  ln -s /usr/bin/pip3 /usr/bin/pip
fi

echo "Done"

