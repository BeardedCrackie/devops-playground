# Talos Cluster Architecture

## Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    DevOps Playground Repository                  │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              infra/clusters/                             │   │
│  │                                                          │   │
│  │  ┌──────────────────────┐    ┌──────────────────────┐  │   │
│  │  │   Phase 1: Provision │    │  Phase 2: Bootstrap  │  │   │
│  │  │                      │    │                      │  │   │
│  │  │  terragrunt.hcl      │───▶│  terragrunt.hcl      │  │   │
│  │  │  terraform.tfvars    │    │  terraform.tfvars    │  │   │
│  │  │                      │    │                      │  │   │
│  │  │  Creates:            │    │  Configures:         │  │   │
│  │  │  • VM instances      │    │  • Talos config      │  │   │
│  │  │  • Network setup     │    │  • Cluster init      │  │   │
│  │  │  • Storage           │    │  • Node join         │  │   │
│  │  │  • IP addresses      │    │  • Kubeconfig        │  │   │
│  │  └──────────────────────┘    └──────────────────────┘  │   │
│  │                                                          │   │
│  │  Root Configuration:                                    │   │
│  │  • terragrunt.hcl (common settings)                     │   │
│  │  • terragrunt.stack.hcl (orchestration)                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  External Modules │
                    │  (infra-playground)│
                    │                   │
                    │  • Provision code │
                    │  • Bootstrap code │
                    └──────────────────┘
                              │
                              ▼
            ┌─────────────────────────────────┐
            │      Proxmox Infrastructure      │
            │                                  │
            │  ┌────────────┐  ┌────────────┐ │
            │  │ Control    │  │  Worker    │ │
            │  │ Plane VMs  │  │  Node VMs  │ │
            │  └────────────┘  └────────────┘ │
            │                                  │
            │       Talos Kubernetes           │
            └─────────────────────────────────┘
```

## Workflow Sequence

```
User Actions                    Terragrunt                    Infrastructure
     │                               │                              │
     │ 1. Edit terraform.tfvars      │                              │
     ├──────────────────────────────▶│                              │
     │                               │                              │
     │ 2. terragrunt run-all init    │                              │
     ├──────────────────────────────▶│                              │
     │                               │ Download modules             │
     │                               ├─────────────────────────────▶│
     │                               │                              │
     │ 3. terragrunt run-all apply   │                              │
     ├──────────────────────────────▶│                              │
     │                               │                              │
     │                               │ Phase 1: Provision           │
     │                               ├─────────────────────────────▶│
     │                               │ Create VMs                   │
     │                               │◀─────────────────────────────┤
     │                               │ (Returns: IPs, names)        │
     │                               │                              │
     │                               │ Phase 2: Bootstrap           │
     │                               ├─────────────────────────────▶│
     │                               │ Configure Talos              │
     │                               │ Initialize cluster           │
     │                               │◀─────────────────────────────┤
     │                               │ (Returns: kubeconfig)        │
     │                               │                              │
     │◀──────────────────────────────┤                              │
     │ Cluster ready!                │                              │
     │                               │                              │
     │ 4. kubectl get nodes          │                              │
     ├──────────────────────────────────────────────────────────────▶│
     │◀──────────────────────────────────────────────────────────────┤
     │ Display cluster nodes         │                              │
```

## File Dependency Graph

```
terragrunt.stack.hcl
    │
    ├─▶ provision/
    │      ├─▶ terragrunt.hcl
    │      │      ├─ Includes: ../terragrunt.hcl (root)
    │      │      └─ Source: external module
    │      └─▶ terraform.tfvars (user config)
    │
    └─▶ bootstrap/
           ├─▶ terragrunt.hcl
           │      ├─ Includes: ../terragrunt.hcl (root)
           │      ├─ Depends on: ../provision
           │      └─ Source: external module
           └─▶ terraform.tfvars (user config)
```

## Configuration Flow

```
1. User Configuration
   └─▶ terraform.tfvars (Proxmox settings, VM specs, network)

2. Terragrunt Processing
   └─▶ Merges with root config
   └─▶ Passes to external module
   └─▶ External module runs Terraform

3. Terraform Execution
   └─▶ Creates infrastructure via Proxmox API
   └─▶ Outputs VM details

4. Bootstrap Dependencies
   └─▶ Reads provision outputs
   └─▶ Generates Talos configs
   └─▶ Applies to VMs
   └─▶ Initializes Kubernetes

5. Final Output
   └─▶ Kubeconfig for cluster access
   └─▶ Cluster endpoint information
```

## Universal Design

The setup is universal because:

1. **Configurable**: All infrastructure details via tfvars
2. **Modular**: Separate provision and bootstrap phases
3. **Reusable**: Same structure for any environment
4. **Extensible**: Easy to adapt for AWS, Azure, etc.
5. **Maintainable**: External modules for core logic

### Adapting for Different Platforms

**Current (Proxmox)**:
```
provision/ → Creates Proxmox VMs → IPs
bootstrap/ → Uses IPs → Configures Talos
```

**AWS Example**:
```
provision/ → Creates EC2 instances → IPs
bootstrap/ → Uses IPs → Configures Talos
```

**Azure Example**:
```
provision/ → Creates Azure VMs → IPs
bootstrap/ → Uses IPs → Configures Talos
```

The bootstrap phase is **platform-agnostic** - it only needs IP addresses!
