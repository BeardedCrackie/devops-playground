# devops-playground/infra

Infrastructure-as-code configurations for provisioning and managing Kubernetes clusters.

## Directory Structure

```
infra/
├── clusters/              # Talos Kubernetes cluster provisioning and bootstrap
│   ├── provision/         # Phase 1: VM provisioning on Proxmox
│   ├── bootstrap/         # Phase 2: Talos cluster bootstrap
│   ├── README.md          # Detailed setup guide
│   └── quickstart.sh      # Interactive setup script
└── management/            # Management tools and configurations
    ├── ansible/           # Ansible playbooks
    └── scripts/           # Utility scripts
```

## Talos Kubernetes Clusters

The `clusters/` directory contains a universal, two-phase approach for provisioning and bootstrapping Talos Kubernetes clusters using Terraform and Terragrunt.

### Quick Start

```bash
cd clusters

# Setup configuration
./quickstart.sh

# Or manually:
# 1. Configure provisioning
cp provision/terraform.tfvars.example provision/terraform.tfvars
# Edit provision/terraform.tfvars with your Proxmox settings

# 2. Configure bootstrap (optional)
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
# Edit bootstrap/terraform.tfvars with your cluster settings

# 3. Initialize and apply
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

For detailed documentation, see:
- [clusters/README.md](clusters/README.md) - Complete setup guide
- [clusters/UNIVERSAL_BOOTSTRAP_GUIDE.md](clusters/UNIVERSAL_BOOTSTRAP_GUIDE.md) - Universal design principles

## Prerequisites

Install required tools (Terraform, Terragrunt, Ansible):

```bash
cd ../scripts
./venv-setup.sh
source ./venv-activate.sh
```

## Legacy Infrastructure

### Proxmox Ubuntu with MicroK8s

For provisioning Ubuntu VMs with MicroK8s using Terraform and Ansible:

1. **Proxmox connection**: Configure in terraform/.auto.tfvars
2. **Ansible requirements**: Install ansible role `istvano.microk8s`
3. **Provision**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
