data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.aws_num_azs)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.aws_name_prefix
  cidr = var.aws_vpc_cidr
  azs  = local.azs

  public_subnets = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr, 8, k)]
  #private_subnets  = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr, 8, k + var.aws_num_azs)]
  #database_subnets = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr, 8, k + (var.aws_num_azs * 2))]

  enable_dns_support   = true
  enable_dns_hostnames = true

  #enable_nat_gateway = true
  #single_nat_gateway = true

  #create_database_subnet_group = false

  tags = local.aws_tags
}
