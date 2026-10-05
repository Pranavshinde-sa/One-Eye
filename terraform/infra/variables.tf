variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
  default     = "one-eye"
}

variable "node_count" {
  description = "Number of EC2 nodes. The first one is the K3s server, the rest are agents"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "EC2 size. K3s server needs about 2 GB RAM, so t3.small is the minimum"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "Contents of your SSH public key (the .pub file)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Who can SSH to the nodes, for example 203.0.113.10/32"
  type        = string
}
