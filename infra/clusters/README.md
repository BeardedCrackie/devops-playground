# Talos Kubernetes Cluster with Terraform and Terragrunt

This directory contains the infrastructure-as-code setup for provisioning and bootstrapping Talos Kubernetes clusters using Terraform and Terragrunt.

## Overview

The setup is divided into two phases:

1. **Provision Phase**: Creates Talos VMs on Proxmox infrastructure
2. **Bootstrap Phase**: Configures and bootstraps the Talos cluster on the provisioned VMs

Both phases use Terragrunt to manage dependencies and orchestration, making the process universal and reusable across different environments.

## Directory Structure

```
clusters/
├── terragrunt.stack.hcl          # Terragrunt stack configuration
├── provision/
│   ├── terragrunt.hcl            # Provision unit configuration
│   └── terraform.tfvars.example  # Example variables for provisioning
├── bootstrap/
│   ├── terragrunt.hcl            # Bootstrap unit configuration
│   └── terraform.tfvars.example  # Example variables for bootstrap
└── README.md                     # This file
```

## Prerequisites

1. **Install required tools** (automated via scripts):
   ```bash
   cd ../..
   ./scripts/venv-setup.sh
   source ./scripts/venv-activate.sh
   ```
   This installs:
   - Terraform
   - Terragrunt
   - Ansible (for additional automation)

2. **Proxmox access**: Ensure you have:
   - Proxmox host accessible from your machine
   - API credentials (user and password/token)
   - A Talos Linux template or ISO uploaded to Proxmox

3. **SSH access**: Ensure you can SSH to the Proxmox host if needed

## Quick Start

### Phase 1: Provision Talos VMs

1. **Configure provisioning variables**:
   ```bash
   cd provision
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your Proxmox settings
   ```

2. **Initialize and provision**:
   ```bash
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

   Or use the stack to run both phases:
   ```bash
   cd ..  # Back to clusters directory
   terragrunt run-all init
   terragrunt run-all plan
   ```

3. **Verify VMs are created** in Proxmox web UI

### Phase 2: Bootstrap Talos Cluster

After VMs are provisioned, bootstrap the cluster:

1. **Configure bootstrap variables** (optional, has sensible defaults):
   ```bash
   cd bootstrap
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars if you need custom configuration
   ```

2. **Bootstrap the cluster**:
   ```bash
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

   Or run from the stack:
   ```bash
   cd ..  # Back to clusters directory
   terragrunt run-all apply
   ```

3. **Access your cluster**:
   The bootstrap process will output kubeconfig information. Save it to access your cluster:
   ```bash
   # Get the kubeconfig from terraform output
   terragrunt output -raw kubeconfig > ~/.kube/talos-config
   export KUBECONFIG=~/.kube/talos-config
   
   # Verify cluster access
   kubectl get nodes
   ```

## Using the Terragrunt Stack

The `terragrunt.stack.hcl` file defines the complete infrastructure stack with dependencies:

```bash
# Initialize all units
terragrunt run-all init

# Plan changes for all units
terragrunt run-all plan

# Apply all units in dependency order (provision first, then bootstrap)
terragrunt run-all apply

# Destroy all units in reverse dependency order
terragrunt run-all destroy
```

## Configuration

### Provision Phase Variables

Key variables you can customize in `provision/terraform.tfvars`:

- `proxmox_host`: Proxmox server hostname/IP
- `proxmox_user`: API user (e.g., `root@pam`)
- `cluster_name`: Name for your Talos cluster
- `control_plane_count`: Number of control plane nodes (default: 3)
- `worker_count`: Number of worker nodes (default: 2)
- `control_plane_cores`, `control_plane_memory`: Resources for control plane
- `worker_cores`, `worker_memory`: Resources for workers
- Network settings (bridge, gateway, DNS, IP ranges)

### Bootstrap Phase Variables

Key variables you can customize in `bootstrap/terraform.tfvars`:

- `cluster_endpoint`: Kubernetes API endpoint URL
- `kubernetes_version`: Kubernetes version to deploy
- `cni`: CNI plugin (calico, cilium, flannel)
- `cluster_pod_cidr`: Pod network CIDR
- `cluster_service_cidr`: Service network CIDR
- Feature flags (disk encryption, kube-span, etc.)

## Universal Design

This setup is designed to be universal and reusable:

1. **Separation of Concerns**: Provision and bootstrap are separate phases
2. **Dependency Management**: Terragrunt ensures correct execution order
3. **Flexible Configuration**: All settings via tfvars files
4. **External Modules**: Uses tested modules from `infra-playground` repo
5. **Mock Outputs**: Can plan without provisioned infrastructure
6. **Environment Agnostic**: Works with any Proxmox setup

## Advanced Usage

### Custom Configuration Patches

To apply custom Talos configuration:

1. Create a patch file (e.g., `custom-patch.yaml`)
2. Reference it in `bootstrap/terraform.tfvars`:
   ```hcl
   control_plane_patches = [
     file("${path.module}/custom-patch.yaml")
   ]
   ```

### Multiple Clusters

To manage multiple clusters:

1. Copy the `clusters` directory to a new location (e.g., `clusters-prod`)
2. Customize the configuration for the new cluster
3. Apply each cluster independently

### CI/CD Integration

This setup can be integrated into CI/CD pipelines:

```bash
# In your CI/CD pipeline
export TF_VAR_proxmox_password="${PROXMOX_PASSWORD}"
terragrunt run-all apply -auto-approve
```

## Troubleshooting

### VMs not starting
- Check Proxmox logs
- Verify template/ISO is correct
- Ensure sufficient resources on Proxmox node

### Bootstrap fails
- Verify VMs are running and accessible
- Check network connectivity to VMs
- Review Talos machine configuration

### Dependency errors
```bash
# Clear terragrunt cache
find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# Reinitialize
terragrunt run-all init
```

## Additional Resources

- [Talos Linux Documentation](https://www.talos.dev/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

## Next Steps

After bootstrapping your cluster:

1. Install additional components (ingress, storage, monitoring)
2. Configure GitOps with ArgoCD (see `gitops/` directory)
3. Deploy applications (see `apps/` directory)
