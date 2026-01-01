# Talos Terraform Bootstrap - Quick Reference

## Prerequisites Setup
```bash
# One-time setup
cd /path/to/devops-playground
./scripts/venv-setup.sh
source ./scripts/venv-activate.sh
```

## Initial Configuration
```bash
cd infra/clusters

# Option 1: Use interactive script
./quickstart.sh

# Option 2: Manual setup
cp provision/terraform.tfvars.example provision/terraform.tfvars
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
# Edit files with your settings
```

## Common Commands

### Initialize
```bash
# Initialize all units
terragrunt run-all init

# Or individually
cd provision && terragrunt init
cd ../bootstrap && terragrunt init
```

### Plan
```bash
# Plan all changes
terragrunt run-all plan

# Or individually
cd provision && terragrunt plan
cd ../bootstrap && terragrunt plan
```

### Apply
```bash
# Apply everything (recommended for first run)
terragrunt run-all apply

# Or step by step
cd provision && terragrunt apply     # Creates VMs
cd ../bootstrap && terragrunt apply  # Bootstraps cluster
```

### Destroy
```bash
# Destroy everything
terragrunt run-all destroy

# Or individually (reverse order)
cd bootstrap && terragrunt destroy
cd ../provision && terragrunt destroy
```

## Get Cluster Access

### Extract Kubeconfig
```bash
cd bootstrap
terragrunt output -raw kubeconfig > ~/.kube/talos-config
export KUBECONFIG=~/.kube/talos-config
kubectl get nodes
```

### Get Talos Config
```bash
cd bootstrap
terragrunt output -raw talosconfig > ~/.talos/config
export TALOSCONFIG=~/.talos/config
talosctl health
```

## Cluster Information

### View Outputs
```bash
# All outputs
cd provision && terragrunt output
cd bootstrap && terragrunt output

# Specific output
terragrunt output control_plane_ips
terragrunt output cluster_endpoint
```

### Check Cluster Status
```bash
# Kubernetes
export KUBECONFIG=~/.kube/talos-config
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info

# Talos
export TALOSCONFIG=~/.talos/config
talosctl --nodes <node-ip> version
talosctl --nodes <node-ip> dashboard
```

## Troubleshooting

### View Logs
```bash
# Terragrunt logs (verbose)
terragrunt apply --terragrunt-log-level debug

# Talos node logs
talosctl -n <node-ip> logs controller-runtime
talosctl -n <node-ip> logs kubelet
```

### State Management
```bash
# Show current state
terragrunt show

# List resources
terragrunt state list

# Refresh state
terragrunt refresh
```

### Cache Issues
```bash
# Clear terragrunt cache
find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# Clear terraform cache
find . -type d -name ".terraform" -exec rm -rf {} +

# Reinitialize
terragrunt run-all init
```

## Configuration Updates

### Update VM Count
```bash
# Edit provision/terraform.tfvars
worker_count = 5  # Change from 2 to 5

# Apply changes
cd provision
terragrunt apply

# Bootstrap new nodes
cd ../bootstrap
terragrunt apply
```

### Update Kubernetes Version
```bash
# Edit bootstrap/terraform.tfvars
kubernetes_version = "v1.30.0"

# Apply update
cd bootstrap
terragrunt apply
```

### Change Module Version
```bash
# Edit provision/terragrunt.hcl or bootstrap/terragrunt.hcl
source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/provision?ref=v0.2.0"

# Reinitialize
terragrunt init -upgrade
```

## Multiple Clusters

### Setup Second Cluster
```bash
# Copy clusters directory
cp -r infra/clusters infra/clusters-prod

# Update configuration
cd infra/clusters-prod
# Edit terraform.tfvars files with different settings

# Apply
terragrunt run-all apply
```

## Environment Variables

### Proxmox Authentication
```bash
# Set via environment (recommended for CI/CD)
export TF_VAR_proxmox_password="your-password"
export TF_VAR_proxmox_api_token="your-token"
```

### Terragrunt Options
```bash
export TERRAGRUNT_LOG_LEVEL=debug
export TERRAGRUNT_NON_INTERACTIVE=true  # For CI/CD
```

## CI/CD Integration

### Pipeline Example
```bash
#!/bin/bash
# ci-deploy.sh

# Setup
source ./scripts/venv-activate.sh
cd infra/clusters

# Set credentials
export TF_VAR_proxmox_password="${CI_PROXMOX_PASSWORD}"

# Deploy
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply -auto-approve

# Output kubeconfig
cd bootstrap
terragrunt output -raw kubeconfig > /tmp/kubeconfig
# Upload kubeconfig artifact
```

## Module Development

### Test Local Module
```bash
# Edit terragrunt.hcl to use local module
terraform {
  source = "../../../modules/talos-provision"
}

# Apply
terragrunt apply
```

### Switch Back to Remote Module
```bash
# Edit terragrunt.hcl
terraform {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/provision?ref=v0.1.1"
}

# Reinitialize
terragrunt init -reconfigure
```

## Best Practices

### Before Making Changes
```bash
# Always plan first
terragrunt run-all plan

# Review changes carefully
# Especially resource deletions/replacements
```

### State Backup
```bash
# Backup state before major changes
cp -r .terraform* backup/
cp terraform.tfstate* backup/
```

### Version Pinning
```bash
# Pin module versions in production
source = "git::...?ref=v0.1.1"  # Good
# source = "git::...?ref=main"  # Avoid in production
```

### Secrets Management
```bash
# Never commit secrets
# Use environment variables or secret managers
export TF_VAR_proxmox_password="${SECRET}"

# Or use .tfvars (gitignored)
proxmox_password = var.proxmox_password  # Read from env
```

## Help & Resources

### Get Help
```bash
# Terragrunt help
terragrunt --help
terragrunt apply --help

# View module documentation
# See external module repository README
```

### Documentation Links
- README.md - Complete setup guide
- UNIVERSAL_BOOTSTRAP_GUIDE.md - Design principles
- ARCHITECTURE.md - Visual diagrams
- terraform.tfvars.example - Configuration reference

### Common Issues
| Issue | Solution |
|-------|----------|
| VMs not starting | Check Proxmox logs, verify template |
| Network timeout | Verify firewall, check VM IPs |
| Bootstrap fails | Ensure VMs are running, check connectivity |
| State locked | `terragrunt force-unlock <lock-id>` |
| Module download fails | Check SSH keys, network connectivity |
