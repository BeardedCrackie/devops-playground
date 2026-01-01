#!/bin/bash
# Quickstart script for Talos cluster provisioning and bootstrap

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTERS_DIR="$SCRIPT_DIR"

echo "=========================================="
echo "Talos Cluster Setup - Quickstart"
echo "=========================================="
echo ""

# Check if terragrunt is installed
if ! command -v terragrunt &> /dev/null; then
    echo "❌ Terragrunt not found. Please install it first:"
    echo "   Run: ../../scripts/venv-setup.sh && source ../../scripts/venv-activate.sh"
    exit 1
fi

echo "✅ Terragrunt found: $(terragrunt --version | head -1)"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install it first:"
    echo "   Run: ../../scripts/venv-setup.sh && source ../../scripts/venv-activate.sh"
    exit 1
fi

echo "✅ Terraform found: $(terraform version | head -1)"
echo ""

# Function to setup configuration
setup_config() {
    local phase=$1
    local dir="$CLUSTERS_DIR/$phase"
    
    echo "Setting up $phase configuration..."
    
    if [ -f "$dir/terraform.tfvars" ]; then
        echo "⚠️  $phase/terraform.tfvars already exists"
        read -p "   Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "   Skipping $phase configuration"
            return
        fi
    fi
    
    if [ -f "$dir/terraform.tfvars.example" ]; then
        cp "$dir/terraform.tfvars.example" "$dir/terraform.tfvars"
        echo "✅ Created $phase/terraform.tfvars from example"
        echo "   Please edit $dir/terraform.tfvars with your settings"
    else
        echo "⚠️  No example file found at $dir/terraform.tfvars.example"
    fi
}

# Main menu
echo "What would you like to do?"
echo "1) Setup configuration files"
echo "2) Initialize Terragrunt (run-all init)"
echo "3) Plan infrastructure (run-all plan)"
echo "4) Apply infrastructure (run-all apply)"
echo "5) Provision VMs only (provision phase)"
echo "6) Bootstrap cluster only (bootstrap phase)"
echo "7) Destroy infrastructure (run-all destroy)"
echo "8) Exit"
echo ""
read -p "Enter choice [1-8]: " choice

case $choice in
    1)
        setup_config "provision"
        setup_config "bootstrap"
        echo ""
        echo "✅ Configuration files created"
        echo "📝 Next steps:"
        echo "   1. Edit provision/terraform.tfvars with your Proxmox settings"
        echo "   2. Edit bootstrap/terraform.tfvars with your cluster settings"
        echo "   3. Run this script again and choose option 2 (Initialize)"
        ;;
    2)
        echo "Initializing all units..."
        cd "$CLUSTERS_DIR"
        terragrunt run-all init
        echo "✅ Initialization complete"
        ;;
    3)
        echo "Planning infrastructure changes..."
        cd "$CLUSTERS_DIR"
        terragrunt run-all plan
        ;;
    4)
        echo "⚠️  This will provision VMs and bootstrap the Talos cluster"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$CLUSTERS_DIR"
            terragrunt run-all apply
            echo ""
            echo "✅ Infrastructure applied successfully"
            echo "📝 To access your cluster:"
            echo "   cd bootstrap"
            echo "   terragrunt output -raw kubeconfig > ~/.kube/talos-config"
            echo "   export KUBECONFIG=~/.kube/talos-config"
            echo "   kubectl get nodes"
        fi
        ;;
    5)
        echo "Provisioning VMs only..."
        cd "$CLUSTERS_DIR/provision"
        terragrunt init
        terragrunt apply
        ;;
    6)
        echo "Bootstrapping cluster only..."
        cd "$CLUSTERS_DIR/bootstrap"
        terragrunt init
        terragrunt apply
        ;;
    7)
        echo "⚠️  This will DESTROY all provisioned infrastructure"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$CLUSTERS_DIR"
            terragrunt run-all destroy
            echo "✅ Infrastructure destroyed"
        fi
        ;;
    8)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
