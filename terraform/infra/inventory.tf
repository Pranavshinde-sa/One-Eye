locals {
  ansible_inventory = <<-EOT
[k3s_server]
${module.ec2.server_public_ip}

[k3s_agents]
${join("\n", module.ec2.agent_public_ips)}

[k3s:children]
k3s_server
k3s_agents

[k3s:vars]
ansible_user=ubuntu
k3s_server_private_ip=${module.ec2.server_private_ip}
EOT
}

resource "local_file" "ansible_inventory" {
  content  = local.ansible_inventory
  filename = "${path.module}/../../ansible/inventory.ini"
}
