#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$SCRIPT_DIR/.."

sudo apt install python3.12-venv curl unzip

# Create a Python virtual environment in the ansible folder
python3 -m venv $INFRA_DIR/venv

# Activate the virtual environment
source $INFRA_DIR/venv/bin/activate

# Upgrade pip and install Ansible and Kubernetes Python client
pip install --upgrade pip
pip install ansible kubernetes

# Install Ansible roles
ansible-galaxy install -r $SCRIPT_DIR/requirements.yml

# Download and install Terraform CLI in the virtualenv's bin folder
TERRAFORM_VERSION="1.12.2"
TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}"

echo "Installing Terraform ${TERRAFORM_VERSION}..."

curl -fsSLo /tmp/${TERRAFORM_ZIP} ${TERRAFORM_URL}
unzip -o /tmp/${TERRAFORM_ZIP} -d ../venv/bin/
chmod +x ../venv/bin/terraform
rm /tmp/${TERRAFORM_ZIP}

# Test Terraform install
terraform version

# Deactivate the virtual environment
deactivate

echo "Virtual environment setup complete. Ansible and Terraform are installed."
