#!/bin/bash
#
# Installs common development tools (admin level access required)
#
set -eo pipefail

. $(dirname $0)/shared-lib.sh

echo "Checking user"
if [[ "$USER" != "root" ]]; then
  echo "Script must be run as root or using sudo!"
  exit 1
fi

echo "Setting up temp dir for downloads"
mkdir -p temp
cd temp

echo "Intalling AWS CLI"
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
download "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" "awscliv2.zip"
unzip awscliv2.zip
./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

# TODO make configurable
# echo "Cleaning up"
# rm -rf temp

echo "Done"

