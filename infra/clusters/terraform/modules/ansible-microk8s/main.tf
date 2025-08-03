resource "null_resource" "ansible_inventory" {
  provisioner "local-exec" {
    command = <<-EOT
      # Generate inventory file
      echo "[microk8s]" > ../ansible/inventory.ini
      i=1
      for ip in ${join(" ", var.vm_ips)}; do
        echo "microk8s-node-$i ansible_host=$ip ansible_user=${var.vm_username} ansible_ssh_private_key_file=${var.priv_key_path}" >> ../ansible/inventory.ini
        i=$((i+1))
      done
    EOT
  }
}

resource "null_resource" "after_provisionsetup" {
  depends_on = [null_resource.ansible_inventory]
  provisioner "local-exec" {
    command = <<-EOT
      # Activate Python virtual environment and run Ansible
      source ../venv/bin/activate
      ../venv/bin/ansible-playbook -i ../ansible/inventory.ini ../ansible/after-provision-setup.yaml \
        -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'"
    EOT
  }
}

resource "null_resource" "ansible_setup_microk8s" {
  depends_on = [null_resource.after_provisionsetup]
  provisioner "local-exec" {
    command = <<-EOT
      # Activate Python virtual environment and run Ansible
      source ../venv/bin/activate
      ../venv/bin/ansible-playbook -i ../ansible/inventory.ini ../ansible/microk8s-setup.yaml \
        -e "ansible_user=${var.vm_username}"
    EOT
  }
}

resource "null_resource" "ansible_kubeconfig" {
  depends_on = [null_resource.ansible_setup_microk8s]
  provisioner "local-exec" {
    command = <<-EOT
      # Activate Python virtual environment and run Ansible
      source ../venv/bin/activate
      ../venv/bin/ansible-playbook -i ../ansible/inventory.ini ../ansible/microk8s-kubeconfig.yaml \
        -e "ansible_user=${var.vm_username}"
    EOT
  }
}

data "local_file" "kubeconfig" {
  depends_on = [null_resource.ansible_kubeconfig]
  filename   = "kubeconfig"
}

output "kubeconfig_path" {
  value       = data.local_file.kubeconfig.filename
  description = "Path to the generated kubeconfig file."
}

output "kubeconfig_content" {
  value      = data.local_file.kubeconfig.content
  sensitive  = true
  description = "Kubeconfig file content as a string"
}
