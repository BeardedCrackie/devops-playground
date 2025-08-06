# Tasklist Kustomize Configuration

This directory contains Kustomize configuration for the Tasklist application, replacing the previous Helm charts.

## Structure

```
kustomize/
├── base/                          # Base resources (environment-agnostic)
│   ├── deployment-backend.yaml
│   ├── deployment-celery.yaml
│   ├── deployment-frontend.yaml
│   ├── deployment-mongo.yaml
│   ├── deployment-rabbitmq.yaml
│   ├── ingress.yaml
│   ├── kustomization.yaml         
│   ├── pvc-mongo.yaml
│   ├── pvc-rabbitmq.yaml
│   ├── service-backend.yaml
│   ├── service-frontend.yaml
│   ├── service-mongo.yaml
│   └── service-rabbitmq.yaml
└── overlays/                      # Environment-specific overrides
    ├── dev/
    │   └── kustomization.yaml     # Development environment config
    └── prod/
        └── kustomization.yaml     # Production environment config
```

## Components

The base configuration includes:

- **Backend**: FastAPI application with MongoDB and RabbitMQ connectivity
- **Frontend**: Static web application served via nginx
- **Celery**: Background task worker using the same backend image
- **MongoDB**: Database with persistent storage
- **RabbitMQ**: Message broker with management interface and persistent storage
- **Ingress**: Routes traffic to appropriate services

## Usage

### Deploy to Development Environment

```bash
kubectl apply -k overlays/dev
```

### Deploy to Production Environment

```bash
kubectl apply -k overlays/prod
```

### Build and View Configuration

```bash
# View development configuration
kustomize build overlays/dev

# View production configuration
kustomize build overlays/prod
```

## Environment Differences

### Development (dev)
- Namespace: `tasklist-dev`
- Name prefix: `dev-`
- Image tags: `dev-latest`
- Host: `dev.localhost`
- Resource limits: Lower limits suitable for development
- Single replica for all services

### Production (prod)
- Namespace: `tasklist-prod`
- Name prefix: `prod-`
- Image tags: `v1.0.0`
- Host: `tasklist.example.com`
- Resource limits: Higher limits for production workloads
- Multiple replicas for high availability:
  - Backend: 3 replicas
  - Frontend: 2 replicas
  - Celery: 2 replicas
- Larger persistent volumes:
  - MongoDB: 10Gi
  - RabbitMQ: 5Gi

## Customization

To create additional overlays (e.g., staging), create a new directory under `overlays/` and customize:

1. Namespace
2. Image tags
3. Resource limits
4. Replica counts
5. Ingress hostnames
6. Storage sizes

## Migration from Helm

This Kustomize configuration provides equivalent functionality to the previous Helm chart with these advantages:

- **Simpler templating**: No complex Helm templating syntax
- **GitOps friendly**: Plain YAML files that are easier to review
- **Environment-specific patches**: Clear separation of base and environment-specific configuration
- **Native Kubernetes**: Uses standard Kubernetes YAML without additional abstraction
