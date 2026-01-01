# Getting Started with Talos Bootstrap

This is a step-by-step guide for first-time users to get a Talos Kubernetes cluster up and running.

## What You'll Get

By following this guide, you'll have:
- 3 control plane VMs running Talos Linux
- 2 worker node VMs running Talos Linux
- A fully functioning Kubernetes cluster
- A kubeconfig file to access your cluster
- All managed via Terraform and Terragrunt

## Prerequisites

### Required Access
- ✅ A Proxmox server with API access
- ✅ Username and password/API token for Proxmox
- ✅ Sufficient resources: ~20GB RAM, ~40GB storage, ~16 vCPUs
- ✅ Network access to Proxmox from your machine

### Required Software
All tools will be installed automatically by the setup script!

## Step-by-Step Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/BeardedCrackie/devops-playground.git
cd devops-playground
```

### Step 2: Install Required Tools

Run the automated setup script:

```bash
./scripts/venv-setup.sh
source ./scripts/venv-activate.sh
```

This installs:
- Terraform (for infrastructure provisioning)
- Terragrunt (for orchestration)
- Ansible (for additional automation)
- Kustomize (for Kubernetes manifests)

**Verify installation:**
```bash
terraform --version    # Should show v1.12.2
terragrunt --version   # Should show v0.85.0
```

### Step 3: Navigate to Clusters Directory

```bash
cd infra/clusters
```

### Step 4: Configure Your Environment

#### Option A: Interactive Setup (Recommended for First-Time Users)

```bash
./quickstart.sh
```

Choose option `1) Setup configuration files`, then:
1. Edit `provision/terraform.tfvars` with your Proxmox details
2. Edit `bootstrap/terraform.tfvars` with your cluster preferences (optional)

#### Option B: Manual Setup

```bash
# Copy example files
cp provision/terraform.tfvars.example provision/terraform.tfvars
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars

# Edit provision config
nano provision/terraform.tfvars
```

### Step 5: Configure Proxmox Connection

Edit `provision/terraform.tfvars`:

```hcl
# Proxmox server details
proxmox_host = "192.168.1.100"        # Your Proxmox IP
proxmox_port = 8006
proxmox_user = "root@pam"
proxmox_node = "pve"                  # Your Proxmox node name

# Network settings
network_bridge = "vmbr0"              # Your bridge name
network_gateway = "192.168.1.1"       # Your gateway
network_dns = ["8.8.8.8", "8.8.4.4"]

# IP addresses for VMs (adjust to your network)
control_plane_ip_start = "192.168.1.10"
worker_ip_start = "192.168.1.20"

# Cluster name
cluster_name = "talos-k8s"

# VM specs (adjust based on available resources)
control_plane_count = 3
control_plane_cores = 4
control_plane_memory = 8192

worker_count = 2
worker_cores = 4
worker_memory = 8192
```

**Set your Proxmox password:**
```bash
export TF_VAR_proxmox_password="your-proxmox-password"
```

### Step 6: Configure Cluster Settings (Optional)

Edit `bootstrap/terraform.tfvars` if you want to customize:

```hcl
# Cluster endpoint (will be first control plane IP by default)
cluster_endpoint = "https://talos.k8s.local:6443"

# Kubernetes version
kubernetes_version = "v1.29.0"

# CNI (Container Network Interface)
cni = "cilium"  # Options: calico, cilium, flannel

# Network CIDRs
cluster_pod_cidr = "10.244.0.0/16"
cluster_service_cidr = "10.96.0.0/12"
```

**Note:** If you skip this, sensible defaults will be used.

### Step 7: Initialize Terragrunt

```bash
terragrunt run-all init
```

This will:
- Download required Terraform providers
- Download external modules
- Initialize both provision and bootstrap units

**Expected output:**
```
Terraform has been successfully initialized!
```

### Step 8: Preview Changes

```bash
terragrunt run-all plan
```

Review the plan carefully. You should see:
- VMs to be created (control plane + workers)
- Network configurations
- Talos configurations

### Step 9: Deploy the Cluster

```bash
terragrunt run-all apply
```

Confirm by typing `yes` when prompted.

**This will take 10-20 minutes** and will:
1. Create VMs on Proxmox
2. Wait for VMs to boot
3. Apply Talos configurations
4. Bootstrap the Kubernetes cluster
5. Join worker nodes

**Monitor progress:**
- Watch the Proxmox web UI for VM creation
- Terragrunt will show progress in the terminal

### Step 10: Get Cluster Access

Once deployment is complete:

```bash
# Navigate to bootstrap directory
cd bootstrap

# Extract kubeconfig
terragrunt output -raw kubeconfig > ~/.kube/talos-config

# Set as active kubeconfig
export KUBECONFIG=~/.kube/talos-config

# Verify cluster access
kubectl get nodes
```

**Expected output:**
```
NAME           STATUS   ROLES           AGE   VERSION
talos-cp-0     Ready    control-plane   5m    v1.29.0
talos-cp-1     Ready    control-plane   5m    v1.29.0
talos-cp-2     Ready    control-plane   5m    v1.29.0
talos-worker-0 Ready    <none>          4m    v1.29.0
talos-worker-1 Ready    <none>          4m    v1.29.0
```

### Step 11: Explore Your Cluster

```bash
# Check all pods
kubectl get pods -A

# Check cluster info
kubectl cluster-info

# Get cluster details
kubectl get nodes -o wide
```

## Congratulations! 🎉

You now have a fully functional Talos Kubernetes cluster!

## Next Steps

### Deploy Applications

```bash
# Example: Deploy nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc nginx
```

### Install Additional Components

Explore the GitOps directory for pre-configured components:

```bash
cd ../../../gitops/base-apps/

# Install ArgoCD for GitOps
kubectl create namespace argocd
kubectl apply -n argocd -f argocd/

# Install Prometheus for monitoring
kubectl create namespace monitoring
kubectl apply -n monitoring -f prometheus/
```

### Deploy Your Own Apps

Check out the `apps/` directory for example applications:

```bash
cd ../../../apps/
# Explore FastAPI backend, frontend, etc.
```

## Common Issues & Solutions

### Issue: "VMs not starting"
**Solution:**
- Check Proxmox web UI for errors
- Verify you have a Talos template or ISO
- Check resource availability on Proxmox

### Issue: "Cannot connect to cluster endpoint"
**Solution:**
- Verify VMs have correct IP addresses
- Check network connectivity: `ping 192.168.1.10`
- Verify firewall rules allow port 6443

### Issue: "Terragrunt command not found"
**Solution:**
```bash
# Activate virtual environment
source ../../scripts/venv-activate.sh
```

### Issue: "Authentication failed to Proxmox"
**Solution:**
```bash
# Re-export your password
export TF_VAR_proxmox_password="your-password"

# Or check username format
# Should be: root@pam or user@pve
```

### Issue: "Not enough resources"
**Solution:**
Reduce cluster size in `provision/terraform.tfvars`:
```hcl
control_plane_count = 1    # Minimum for testing
worker_count = 1
control_plane_memory = 4096
worker_memory = 4096
```

## Cleanup

To destroy the cluster when you're done:

```bash
cd infra/clusters
terragrunt run-all destroy
```

Confirm by typing `yes` when prompted.

## Getting Help

- 📖 [README.md](README.md) - Detailed setup guide
- 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md) - System design
- 📋 [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command cheat sheet
- 🌍 [UNIVERSAL_BOOTSTRAP_GUIDE.md](UNIVERSAL_BOOTSTRAP_GUIDE.md) - Design principles

## Learning Resources

- [Talos Linux Documentation](https://www.talos.dev/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Proxmox Documentation](https://pve.proxmox.com/wiki/)

## Troubleshooting Commands

```bash
# Check terragrunt status
terragrunt run-all status

# View detailed logs
terragrunt apply --terragrunt-log-level debug

# Check Talos node health (requires talosctl)
talosctl -n <node-ip> health

# Force unlock if state is locked
terragrunt force-unlock <lock-id>
```

Happy clustering! 🚀
