data "aws_ami" "rhel8" {
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
      var.rhel_arch
    ]
  }
}

data "aws_ami" "rhel9" {
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
      var.rhel_arch
    ]
  }
}
