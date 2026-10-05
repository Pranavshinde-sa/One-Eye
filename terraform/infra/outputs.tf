output "ecr_repository_url" {
  description = "Push your app image here"
  value       = module.ecr.repository_url
}

output "server_public_ip" {
  value = module.ec2.server_public_ip
}

output "agent_public_ips" {
  value = module.ec2.agent_public_ips
}

output "ansible_inventory" {
  description = "Ready-to-use Ansible inventory"
  value = join("\n", concat(
    [
      "[k3s_server]",
      module.ec2.server_public_ip,
      "",
      "[k3s_agents]",
    ],
    module.ec2.agent_public_ips,
    [
      "",
      "[k3s:children]",
      "k3s_server",
      "k3s_agents",
      "",
      "[k3s:vars]",
      "ansible_user=ubuntu",
      "k3s_server_private_ip=${module.ec2.server_private_ip}",
      "",
    ]
  ))
}