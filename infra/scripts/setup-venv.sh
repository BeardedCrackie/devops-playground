#!/bin/bash

sudo apt install python3.10-venv

# Create a Python virtual environment in the ansible folder
python3 -m venv ../venv

# Activate the virtual environment
source ../venv/bin/activate

# Upgrade pip and install Ansible
pip install --upgrade pip
pip install ansible

# Install Ansible roles
ansible-galaxy install -r requirements.yml

# Deactivate the virtual environment
deactivate

echo "Virtual environment setup complete. Ansible is installed."
