# Discover RHEL AMIs for both x86_64 and arm64 architectures
# This allows mixed-architecture deployments in the same configuration

locals {
  # AMI map for node_os and arch attributes
  # Supports both x86_64 and arm64 for mixed-architecture deployments
  ami_ids = {
    "rhel8-x86_64"  = data.aws_ami.rhel8_x86_64.id
    "rhel8-arm64"   = data.aws_ami.rhel8_arm64.id
    "rhel9-x86_64"  = data.aws_ami.rhel9_x86_64.id
    "rhel9-arm64"   = data.aws_ami.rhel9_arm64.id
    "rhel10-x86_64" = data.aws_ami.rhel10_x86_64.id
    "rhel10-arm64"  = data.aws_ami.rhel10_arm64.id
  }
}

data "aws_ami" "rhel8_x86_64" {
  most_recent = true
  owners = [
    "309956199498",
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.rhel8_ami_name
    ]
  }
  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }
}

data "aws_ami" "rhel8_arm64" {
  most_recent = true
  owners = [
    "309956199498",
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.rhel8_ami_name
    ]
  }
  filter {
    name = "architecture"
    values = [
      "arm64"
    ]
  }
}

data "aws_ami" "rhel9_x86_64" {
  most_recent = true
  owners = [
    "309956199498",
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.rhel9_ami_name
    ]
  }
  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }
}

data "aws_ami" "rhel9_arm64" {
  most_recent = true
  owners = [
    "309956199498",
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.rhel9_ami_name
    ]
  }
  filter {
    name = "architecture"
    values = [
      "arm64"
    ]
  }
}

data "aws_ami" "rhel10_x86_64" {
  most_recent = true
  owners = [
    "309956199498",
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.rhel10_ami_name
    ]
  }
  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }
}

data "aws_ami" "rhel10_arm64" {
  most_recent = true
  owners = [
    "309956199498",
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.rhel10_ami_name
    ]
  }
  filter {
    name = "architecture"
    values = [
      "arm64"
    ]
  }
}
