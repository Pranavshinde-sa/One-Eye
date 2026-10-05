variable "name" {
  type = string
}

variable "node_count" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "ssh_public_key" {
  type = string
}
