locals {
  rhel_ami = var.deploy_with_rhel8 ? data.aws_ami.rhel8 : data.aws_ami.rhel9
}

resource "aws_key_pair" "sandbox_key" {
  key_name   = var.aws_key_name
  public_key = var.aws_key_content

  tags = local.aws_tags
}

resource "aws_instance" "single_node" {
  count = var.deploy_single_node ? var.single_node_instance_count : 0

  instance_type = var.single_node_instance_type
  ami           = var.single_node_image_id != "" ? var.single_node_image_id : local.rhel_ami.id
  key_name      = var.single_node_key_name != "" ? var.single_node_key_name : var.aws_key_name
  subnet_id     = module.vpc.public_subnets.0

  vpc_security_group_ids = [
    aws_security_group.controller.id,
    aws_security_group.single_node.id,
    aws_security_group.single_node_eips.id,
    aws_security_group.default_egress.id
  ]
  root_block_device {
    volume_size = var.single_node_disk_size
  }

  associate_public_ip_address = true

  tags = merge(local.aws_tags,
    {
      Name = var.single_node_instance_name
    }
  )
}

resource "aws_eip" "single_node" {
  count = var.deploy_single_node ? var.single_node_instance_count : 0

  instance = aws_instance.single_node[count.index].id
  domain   = "vpc"
}

resource "aws_instance" "controller" {
  count = var.deploy_single_node ? 0 : var.controller_instance_count

  instance_type = var.controller_instance_type
  ami           = var.controller_image_id != "" ? var.controller_image_id : local.rhel_ami.id
  key_name      = var.controller_key_name != "" ? var.controller_key_name : var.aws_key_name
  subnet_id     = module.vpc.public_subnets.0

  vpc_security_group_ids = [
    aws_security_group.controller.id,
    aws_security_group.public_subnets.id,
    aws_security_group.default_egress.id
  ]
  root_block_device {
    volume_size = var.controller_disk_size
  }

  associate_public_ip_address = true

  tags = merge(local.aws_tags,
    {
      Name = "${var.controller_instance_name}${count.index}"
    }
  )
}

resource "aws_eip" "controller" {
  count = var.deploy_single_node ? 0 : var.controller_instance_count

  instance = aws_instance.controller[count.index].id
  domain   = "vpc"
}

resource "aws_instance" "hub" {
  count = var.deploy_single_node ? 0 : var.hub_instance_count

  instance_type = var.hub_instance_type
  ami           = var.hub_image_id != "" ? var.hub_image_id : local.rhel_ami.id
  key_name      = var.hub_key_name != "" ? var.hub_key_name : var.aws_key_name
  subnet_id     = module.vpc.public_subnets.0

  vpc_security_group_ids = [
    aws_security_group.hub.id,
    aws_security_group.public_subnets.id,
    aws_security_group.default_egress.id
  ]
  root_block_device {
    volume_size = var.hub_disk_size
  }

  associate_public_ip_address = true

  tags = merge(local.aws_tags,
    {
      Name = "${var.hub_instance_name}${count.index}"
    }
  )
}

resource "aws_eip" "hub" {
  count = var.deploy_single_node ? 0 : var.hub_instance_count

  instance = aws_instance.hub[count.index].id
  domain   = "vpc"
}

resource "aws_instance" "eda" {
  count = var.deploy_single_node ? 0 : var.eda_instance_count

  instance_type = var.eda_instance_type
  ami           = var.eda_image_id != "" ? var.eda_image_id : local.rhel_ami.id
  key_name      = var.eda_key_name != "" ? var.eda_key_name : var.aws_key_name
  subnet_id     = module.vpc.public_subnets.0

  vpc_security_group_ids = [
    aws_security_group.eda.id,
    aws_security_group.public_subnets.id,
    aws_security_group.default_egress.id
  ]
  root_block_device {
    volume_size = var.eda_disk_size
  }

  associate_public_ip_address = true

  tags = merge(local.aws_tags,
    {
      Name = "${var.eda_instance_name}${count.index}"
    }
  )
}

resource "aws_eip" "eda" {
  count = var.deploy_single_node ? 0 : var.eda_instance_count

  instance = aws_instance.eda[count.index].id
  domain   = "vpc"
}

resource "aws_instance" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  instance_type = var.bastion_instance_type
  ami           = var.bastion_image_id != "" ? var.bastion_image_id : local.rhel_ami.id
  key_name      = var.bastion_key_name != "" ? var.bastion_key_name : var.aws_key_name
  subnet_id     = module.vpc.public_subnets.0

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.public_subnets.id,
    aws_security_group.default_egress.id
  ]
  root_block_device {
    volume_size = var.bastion_disk_size
  }

  associate_public_ip_address = true

  tags = merge(local.aws_tags,
    {
      Name = var.bastion_instance_name
    }
  )
}

resource "aws_eip" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  instance = aws_instance.bastion[count.index].id
  domain   = "vpc"
}
