#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.." 
 
sudo apt update
sudo apt install -y python3-venv curl unzip

# Create a Python virtual environment in the ansible folder
python3 -m venv $ROOT_DIR/venv

# Activate the virtual environment
source $ROOT_DIR/venv/bin/activate

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


KUSTOMIZE_VERSION="v5.7.1"
KUSTOMIZE_TAR="kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"
KUSTOMIZE_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/${KUSTOMIZE_TAR}"
VENV_BIN="../venv/bin"   # Adjust to your venv bin folder

echo "Installing kustomize ${KUSTOMIZE_VERSION}..."

curl -fsSLo /tmp/${KUSTOMIZE_TAR} ${KUSTOMIZE_URL}

# Extract kustomize binary from the tar.gz (it contains just one file named 'kustomize')
tar -xzf /tmp/${KUSTOMIZE_TAR} -C /tmp/

# Move binary to venv bin
mv /tmp/kustomize ${VENV_BIN}/
chmod +x ${VENV_BIN}/kustomize

# Clean up
rm /tmp/${KUSTOMIZE_TAR}

echo "kustomize installed to ${VENV_BIN}/kustomize"


# Install Task CLI
TASK_VERSION="3.24.0"
TASK_TAR="task_linux_amd64.tar.gz"
TASK_URL="https://github.com/go-task/task/releases/download/v${TASK_VERSION}/${TASK_TAR}"

echo "Installing Task ${TASK_VERSION}..."

curl -fsSLo /tmp/${TASK_TAR} ${TASK_URL}

# Extract task binary from the tar.gz (it contains just one file named 'task')
tar -xzf /tmp/${TASK_TAR} -C /tmp/

# Move binary to venv bin
mv /tmp/task ${VENV_BIN}/
chmod +x ${VENV_BIN}/task

# Clean up
rm /tmp/${TASK_TAR}

echo "Task installed to ${VENV_BIN}/task"


# Deactivate the virtual environment
deactivate

echo "Virtual environment setup complete. Ansible and Terraform are installed."
