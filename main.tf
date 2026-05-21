terraform {
  required_version = ">= 1.5.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "deployment" {
  byte_length = 4
}

locals {
  deployment_id = random_id.deployment.hex

  # Process aap_instances to inject IAM profile and merge security groups
  aap_instances_with_profile = {
    for k, v in var.aap_instances : k => merge(v, {
      iam_instance_profile = v.iam_instance_profile != "" ? v.iam_instance_profile : (
        var.create_instance_profile ? aws_iam_instance_profile.aap_instance_profile[0].name : ""
      )
      # Merge default security groups with user-specified ones
      security_groups = distinct(concat(
        lookup(local.default_security_groups, v.node_type, ["base", "instance_eips"]),
        v.security_groups
      ))
    })
  }

  # Process other_instances to merge security groups
  other_instances_with_security = {
    for k, v in var.other_instances : k => merge(v, {
      # Merge default security groups with user-specified ones
      security_groups = distinct(concat(
        lookup(local.default_security_groups, v.node_type, ["base", "instance_eips"]),
        v.security_groups
      ))
    })
  }

  aws_tags = {
    Owner        = var.aws_resource_owner
    Deployer     = "terraform-aap-sandbox"
    DeploymentID = "${local.deployment_id}"
  }
}

resource "aws_key_pair" "sandbox_key" {
  key_name   = var.aws_key_name
  public_key = var.aws_key_content

  tags = local.aws_tags
}

# EC2 Instances Module
module "ec2_instances" {
  source = "./modules/ec2-instances"

  # Merge AAP instances (with IAM profile and security groups) and other instances (with security groups)
  ec2_instances = merge(local.aap_instances_with_profile, local.other_instances_with_security)

  ami_ids       = local.ami_ids
  instance_type = var.aws_instance_type
  key_name      = var.aws_key_name
  arch          = "x86_64"
  subnet_id     = module.vpc.public_subnets[0]

  security_group_ids = merge(
    {
      base          = aws_security_group.base.id
      instance_eips = aws_security_group.instance_eips.id
    },
    local.bastion_count > 0 ? { bastion = aws_security_group.bastion[0].id } : {},
    local.single_node_count > 0 ? { single_node = aws_security_group.single_node[0].id } : {},
    local.gateway_count > 0 ? { gateway = aws_security_group.gateway[0].id } : {}
  )

  tags = local.aws_tags
}
