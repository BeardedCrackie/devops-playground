# Universal Talos Bootstrap with Terraform

This guide explains the universal approach for bootstrapping Talos VMs with Terraform in this repository.

## Architecture Overview

The solution uses a two-phase approach with Terragrunt orchestration:

```
Phase 1: Provision          Phase 2: Bootstrap
┌──────────────────┐        ┌──────────────────┐
│  Proxmox VMs     │───────▶│  Talos Cluster   │
│  - Control Plane │        │  - Apply Config  │
│  - Worker Nodes  │        │  - Init Cluster  │
│  - Network       │        │  - Join Nodes    │
└──────────────────┘        └──────────────────┘
         │                           │
         └──────── Terragrunt ───────┘
              (Dependency Management)
```

## Universal Design Principles

### 1. Separation of Concerns
- **Provision phase**: Infrastructure creation (VMs, networking)
- **Bootstrap phase**: Cluster configuration and initialization
- Clean separation allows independent updates and testing

### 2. Dependency Management
- Terragrunt ensures bootstrap depends on provision
- Mock outputs enable planning without infrastructure
- Automatic state passing between phases

### 3. Configuration Flexibility
- All settings via terraform.tfvars files
- Example files provide templates
- Environment-specific overrides supported

### 4. Reusability
- Works with any Proxmox setup
- Supports multiple clusters
- Template for other environments (AWS, Azure, etc.)

## How It Works

### Step 1: Provision Infrastructure

The provision phase creates:
- Talos VM instances on Proxmox
- Network configuration
- Storage allocation
- Initial VM settings

Outputs from this phase:
```hcl
outputs = {
  control_plane_ips = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
  worker_ips        = ["192.168.1.20", "192.168.1.21"]
  cluster_name      = "talos-k8s"
  cluster_endpoint  = "https://192.168.1.10:6443"
}
```

### Step 2: Bootstrap Cluster

The bootstrap phase uses provision outputs to:
- Generate Talos machine configurations
- Apply configurations to nodes
- Initialize the Kubernetes cluster
- Join worker nodes to the cluster
- Generate kubeconfig for access

### Terragrunt Orchestration

Terragrunt manages the workflow:

```hcl
# bootstrap/terragrunt.hcl
dependency "provision" {
  config_path = "../provision"
  
  # Inputs automatically use provision outputs
  control_plane_ips = dependency.provision.outputs.control_plane_ips
}
```

## Universal Workflow

### For Any Environment

1. **Customize provision variables**:
   ```bash
   cp provision/terraform.tfvars.example provision/terraform.tfvars
   # Edit with your settings
   ```

2. **Customize bootstrap variables** (optional):
   ```bash
   cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
   # Edit with your cluster settings
   ```

3. **Apply infrastructure**:
   ```bash
   terragrunt run-all apply
   ```

The same workflow works for:
- Development clusters (small VMs, fewer nodes)
- Production clusters (larger VMs, more nodes, HA)
- Testing environments (disposable clusters)
- Multiple clusters (different directories)

## Customization Examples

### Small Dev Cluster

```hcl
# provision/terraform.tfvars
control_plane_count  = 1
worker_count         = 1
control_plane_cores  = 2
control_plane_memory = 4096
```

### Production HA Cluster

```hcl
# provision/terraform.tfvars
control_plane_count  = 3
worker_count         = 5
control_plane_cores  = 8
control_plane_memory = 16384
enable_ha_features   = true
```

### Custom Network Setup

```hcl
# provision/terraform.tfvars
network_bridge      = "vmbr1"
network_gateway     = "10.0.0.1"
control_plane_ip_start = "10.0.1.10"
worker_ip_start     = "10.0.1.20"
```

### Custom CNI

```hcl
# bootstrap/terraform.tfvars
cni = "cilium"
cluster_pod_cidr    = "10.240.0.0/16"
cluster_service_cidr = "10.241.0.0/16"
```

## Advanced Features

### Configuration Patches

Apply custom Talos configurations:

```hcl
# bootstrap/terraform.tfvars
control_plane_patches = [
  file("${path.module}/patches/custom-sysctls.yaml"),
  file("${path.module}/patches/audit-policy.yaml")
]
```

Example patch file:
```yaml
# patches/custom-sysctls.yaml
machine:
  sysctls:
    net.ipv4.ip_forward: "1"
    net.bridge.bridge-nf-call-iptables: "1"
```

### Multiple Clusters

Manage multiple independent clusters:

```bash
# Cluster 1: Development
cd clusters-dev
terragrunt run-all apply

# Cluster 2: Production
cd ../clusters-prod
terragrunt run-all apply
```

### Remote State Backend

For team collaboration, configure remote state:

```hcl
# terragrunt.hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Integration with Other Tools

### GitOps (ArgoCD)

After bootstrap, deploy ArgoCD:

```bash
# Get kubeconfig
cd bootstrap
terragrunt output -raw kubeconfig > ~/.kube/talos-config
export KUBECONFIG=~/.kube/talos-config

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Monitoring (Prometheus + Grafana)

Deploy monitoring stack:

```bash
# Use helm charts from apps directory
cd ../../gitops/base-apps/prometheus
kubectl apply -f .
```

### CI/CD (Tekton)

Set up pipelines:

```bash
cd ../../gitops/base-apps/tekton
kubectl apply -f .
```

## Extending to Other Platforms

This universal approach can be adapted for other platforms:

### AWS
Replace provision phase with AWS EC2 instances:
```hcl
# provision/main.tf (AWS version)
resource "aws_instance" "talos_control_plane" {
  count         = var.control_plane_count
  ami           = var.talos_ami
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  
  tags = {
    Name = "talos-cp-${count.index}"
  }
}

output "control_plane_ips" {
  value = aws_instance.talos_control_plane[*].private_ip
}
```

### Azure
Replace provision phase with Azure VMs:
```hcl
# provision/main.tf (Azure version)
resource "azurerm_linux_virtual_machine" "talos_control_plane" {
  count               = var.control_plane_count
  name                = "talos-cp-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  
  network_interface_ids = [azurerm_network_interface.cp[count.index].id]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

output "control_plane_ips" {
  value = azurerm_network_interface.cp[*].private_ip_address
}
```

The bootstrap phase remains the same - it only needs IP addresses!

## Best Practices

1. **Version Control**: Keep tfvars files in git (use secrets management for sensitive data)
2. **Staging Environments**: Test changes in dev before prod
3. **State Management**: Use remote state for team collaboration
4. **Backup**: Keep backups of talosconfig and kubeconfig
5. **Documentation**: Document environment-specific settings
6. **Security**: Use strong authentication, enable encryption
7. **Monitoring**: Monitor cluster health post-bootstrap
8. **Updates**: Plan for Talos and Kubernetes version upgrades

## Troubleshooting

### Provision Phase Issues

**VMs not starting**:
```bash
# Check Proxmox logs
ssh root@proxmox "journalctl -u pve-cluster -f"

# Verify template
cd provision
terragrunt output vm_details
```

**Network connectivity issues**:
```bash
# Verify bridge configuration
ssh root@proxmox "brctl show"

# Check IP assignment
cd provision
terragrunt output control_plane_ips
```

### Bootstrap Phase Issues

**Cannot connect to nodes**:
```bash
# Verify VMs are running
ssh root@proxmox "qm list"

# Test connectivity
ping $(cd provision && terragrunt output -raw control_plane_ips | jq -r '.[0]')
```

**Bootstrap timeout**:
```bash
# Increase timeouts in bootstrap config
# Check node logs
talosctl -n <node-ip> logs
```

### Dependency Issues

**State conflicts**:
```bash
# Clear cache and reinitialize
find . -type d -name ".terragrunt-cache" -exec rm -rf {} +
terragrunt run-all init
```

## Resources

- [Talos Documentation](https://www.talos.dev/docs/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Talos Provider](https://registry.terraform.io/providers/siderolabs/talos/latest/docs)

## Contributing

To improve this universal bootstrap solution:

1. Test with different configurations
2. Document edge cases and solutions
3. Contribute improvements to external modules
4. Share custom patches and configurations
