# OCI Compatible Local Registries

This directory contains configurations for multiple OCI-compatible container registries that can be deployed locally without authentication.

## Available Registry Options

### 1. Zot Registry (Recommended)
**Files**: `zot-*.yaml`

Zot is a lightweight, OCI-compliant registry with a web UI and search capabilities.

**Features**:
- Full OCI compliance
- Built-in web UI at `/`
- Image search functionality
- Minimal resource usage
- No authentication required

**Deploy**:
```bash
kubectl apply -k . -f zot-kustomization.yaml
```

**Access**:
- Registry API: `http://zot-registry.local:5000`
- Web UI: `http://zot-registry.local`
