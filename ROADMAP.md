# 🗺️ Project Roadmap

This roadmap outlines the infrastructure and application goals, progress, and current status.

---

## 🛠️ Infra

### 🚀 Provisioning
- [x] Proxmox Ubuntu provision with Terraform
- [x] Ansible init microk8s
- [x] Proxmox provision Talos with Terraform
- [x] Talos cluster bootstrap with Terraform

### 🧱 Base Apps
- [x] Helm
- [X] Tekton
- [X] ArgoCD
- [X] Prometheus + Grafana
- [ ] RabbitMQ + operator
- [ ] Postgre + Operator
- [ ] Loki
- [ ] Jaeger

---

## 🧩 Apps

### Tasklist
- [x] FastAPI backend
- [x] Frontend
- [x] Docker + Docker Compose setup
- [x] Celery worker for async job
- [x] Persistent data with Mongo
- [x] Basic Helm chart
- [ ] Implement healthchecks
- [ ] Implement metrics
