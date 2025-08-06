# ArgoCD App of Apps

This directory contains the ArgoCD "app of apps" pattern implementation for managing all applications in the devops-playground repository.

## Structure

- `root-app.yaml` - The main ArgoCD Application that manages all other applications
- `applications/` - Directory containing individual Application manifests

## Applications Managed

1. **tasklist-app** - Main application using Helm charts
2. **registry-app** - Container registry application
3. **tekton-app** - Tekton CI/CD pipelines

## Deployment

To deploy the root application and enable GitOps management:

```bash
kubectl apply -f gitops/argocd/root-app.yaml
```

This will:
1. Create the root-app Application in ArgoCD
2. ArgoCD will then automatically deploy all applications defined in the `applications/` directory
3. All applications will be kept in sync with the Git repository

## Features

- **Automated Sync**: All applications are configured with automated sync enabled
- **Self-Healing**: Applications will automatically correct drift from desired state
- **Pruning**: Removed resources will be automatically cleaned up
- **Namespace Management**: Applications will create their target namespaces if they don't exist

## Monitoring

You can monitor the status of all applications through the ArgoCD UI or CLI:

```bash
# List all applications
argocd app list

# Get specific application status
argocd app get root-app
argocd app get tasklist-app
```

## Adding New Applications

To add a new application:
1. Create a new Application manifest in the `applications/` directory
2. Commit and push the changes
3. ArgoCD will automatically detect and deploy the new application
