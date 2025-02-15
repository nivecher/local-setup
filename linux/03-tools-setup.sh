#!/bin/bash
#
# Installs common development tools (admin level access required)
#
set -eo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

. "$SCRIPT_DIR/shared-lib.sh"

echo "Running as $USER"
if [[ "$USER" == "root" ]]; then
	echo "Do not run this script as root or using sudo."
	exit 1
fi

# echo "Setting up temp dir for downloads"
# mkdir -p temp
# cd temp

echo "Intalling AWS CLI"
brew install awscli
# TODO alternate method below
# # https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# download "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" "awscliv2.zip"
# unzip awscliv2.zip
# ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

echo "Installing Terraform"
brew install terraform
# # TODO make cross-platform friendly
# sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
# wget -O- https://apt.releases.hashicorp.com/gpg |
# 	gpg --dearmor |
# 	sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
# gpg --no-default-keyring \
# 	--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
# 	--fingerprint
# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
#     https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
# 	sudo tee /etc/apt/sources.list.d/hashicorp.list
# sudo apt update
# sudo apt-get install terraform

# echo "Installing Terragrunt"
brew install terragrunt

echo "Installing pre-commit"
brew install pre-commit
# sudo apt-get install pre-commit

# echo "Installing Terragrunt"
# TODO

echo "Installing pre-commit"
sudo apt-get install pre-commit

# TODO make configurable
# echo "Cleaning up"
# rm -rf temp

echo "NOTE: Setup complete! All scripts have been run."
echo "Done"
