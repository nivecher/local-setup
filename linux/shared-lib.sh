#!/bin/bash
#
# Shared library of functions
#

# Normalized package manager commands across Linux distros
# apt for Debian-based distros
# dnf for Fedora-based distros
# TODO add brew support for macOS
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

# Downloads a file and puts it in the downloads directory
# $1 - URL
# $2 - Local filename
# returns path of downloaded file
function download() {
  downloads="downloads" # TODO make configurable
  mkdir -p $downloads
  url=$1
  path=$2
  # TODO use wget if curl not available
  curl -s "$url" -o "$path"
}