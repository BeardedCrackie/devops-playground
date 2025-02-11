# devops-playground/infra/clusters

clusters/
├── terraform/              # provision infrastructure



# 1 proxmox connection
change config in terraform/.auto.tfvars.example and save it as terraform/.auto.tfvars

# 3 provision
terraform init
terraform plan
terraform apply
