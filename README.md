# devops-playground

repo-root/
├── apps/                    # Application repositories (code and Dockerfiles)
│   ├── app1/               # Application 1 (e.g., Health Check Microservice)
│   │   ├── src/            # Source code
│   │   ├── Dockerfile      # Dockerfile for this app
│   │   ├── requirements.txt # App dependencies (for Python, etc.)
|   |   ├── docs/                   # Documentation for both app and infra
│   │   └── README.md       # App-specific README
│   ├── app2/               # Application 2 (e.g., To-Do API)
│   └── app3/               # Application 3 (another example app)
│
├── infra/                  # Infrastructure repository (Kubernetes, GitOps, Helm)
│   ├── apps/               # Manifests for multiple apps
│   │   ├── app1/           # App1 specific configs
│   │   │   ├── base/       # Environment-agnostic configurations (e.g., deployment, service)
│   │   │   ├── overlays/   # Environment-specific configurations (e.g., dev, prod)
│   │   │   ├── kustomization.yaml
│   │   │   ├── values.yaml
│   |   |   └── ci-cd/      # CI/CD pipeline definitions (GitHub Actions, GitLab CI)
│   │   ├── app2/           # App2 specific configs
│   │   ├── app3/           # App3 specific configs
│   │   └── helm-chart/     # Optional: Helm charts for all apps
│   ├── clusters/           # Cluster-level configurations
│   │   ├── dev-cluster/    # Dev environment-specific configurations
│   │   ├── prod-cluster/   # Prod environment-specific configurations
│   │   └── staging-cluster/
│   ├── gitops/             # GitOps configurations (ArgoCD/Flux)
│   │   ├── argo-cd.yaml    # ArgoCD installation and configuration
│   │   └── flux.yaml       # Flux configuration (optional, depending on tool)
│   ├── monitoring/         # Monitoring and observability (Prometheus, Grafana)
│   └── README.md           # Infrastructure-specific README
│   ├── README.md           # General project overview
│   ├── gitops-workflows.md # GitOps workflows and usage
│   └── troubleshooting.md  # Troubleshooting steps for app and infra
|
├── .gitignore              # Ignore unnecessary files - linked to subdirs if neede
└── README.md               # General README for the repository

