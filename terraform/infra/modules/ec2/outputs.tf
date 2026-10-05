output "server_public_ip" {
  value = aws_instance.node[0].public_ip
}

output "server_private_ip" {
  value = aws_instance.node[0].private_ip
}

output "agent_public_ips" {
  value = slice(aws_instance.node[*].public_ip, 1, var.node_count)
}

output "agent_private_ips" {
  value = slice(aws_instance.node[*].private_ip, 1, var.node_count)
}