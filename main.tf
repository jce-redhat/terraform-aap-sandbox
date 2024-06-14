terraform {
  required_version = ">= 1.2.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3.0"
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

  aws_tags = {
    Owner        = var.aws_resource_owner
    DeploymentID = "${local.deployment_id}"
  }
}
