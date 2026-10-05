data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "security_group" {
  source           = "./modules/security-group"
  name             = var.project_name
  vpc_id           = data.aws_vpc.default.id
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "iam" {
  source = "./modules/iam"
  name   = var.project_name
}

module "ec2" {
  source                = "./modules/ec2"
  name                  = var.project_name
  node_count            = var.node_count
  instance_type         = var.instance_type
  subnet_id             = sort(data.aws_subnets.default.ids)[0]
  security_group_id     = module.security_group.id
  instance_profile_name = module.iam.instance_profile_name
  ssh_public_key        = var.ssh_public_key
}

module "ecr" {
  source = "./modules/ecr"
  name   = var.project_name
}