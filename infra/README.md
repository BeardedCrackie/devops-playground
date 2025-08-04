# devops-playground/infra/clusters

clusters/
├── terraform/              # provision infrastructure
├── ansible/                # operate infrastructure


# 1 proxmox connection
change config in terraform/.auto.tfvars.example and save it as terraform/.auto.tfvars

# 2 ansible pre requirements
needed ansible with role: istvano.microk8s

# 3 provision
terraform init
terraform plan
terraform apply
