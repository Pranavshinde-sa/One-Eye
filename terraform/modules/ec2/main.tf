data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}

locals {
  node_names = [for i in range(var.node_count) : i == 0 ? "server" : "agent-${i}"]
}

resource "aws_instance" "node" {
  count = var.node_count

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile_name
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" 
  }

  tags = {
    Name = "${var.name}-${local.node_names[count.index]}"
    Role = count.index == 0 ? "server" : "agent"
  }

  lifecycle {
    ignore_changes = [ami] 
  }
}
