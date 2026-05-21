locals {
  # Count instances by node_type across both aap_instances and other_instances
  bastion_count = (
    try(sum([for k, v in var.aap_instances : v.count if v.node_type == "bastion"]), 0) +
    try(sum([for k, v in var.other_instances : v.count if v.node_type == "bastion"]), 0)
  )

  gateway_count = (
    try(sum([for k, v in var.aap_instances : v.count if v.node_type == "gateway"]), 0) +
    try(sum([for k, v in var.other_instances : v.count if v.node_type == "gateway"]), 0)
  )

  single_node_count = (
    try(sum([for k, v in var.aap_instances : v.count if v.node_type == "single-node"]), 0) +
    try(sum([for k, v in var.other_instances : v.count if v.node_type == "single-node"]), 0)
  )

  gateway_needs_ssh = local.bastion_count == 0

  # Default security groups based on node_type
  # Only include node-type-specific groups if instances of that type are deployed
  default_security_groups = {
    "single-node" = concat(
      ["base", "instance_eips"],
      local.single_node_count > 0 ? ["single_node"] : []
    )
    "gateway" = concat(
      ["base", "instance_eips"],
      local.gateway_count > 0 ? ["gateway"] : []
    )
    "controller" = ["base", "instance_eips"]
    "hub"        = ["base", "instance_eips"]
    "eda"        = ["base", "instance_eips"]
    "execution"  = ["base", "instance_eips"]
    "database"   = ["base", "instance_eips"]
    "dashboard"  = ["base", "instance_eips"]
    "bastion" = concat(
      ["base", "instance_eips"],
      local.bastion_count > 0 ? ["bastion"] : []
    )
  }
}

resource "aws_security_group" "base" {
  name        = "${var.aws_name_prefix}-base"
  description = "Base connectivity: VPC internal ingress + internet egress"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "instance_eips" {
  name        = "${var.aws_name_prefix}-instance-eips"
  description = "Communication between all instance Elastic IPs"
  vpc_id      = module.vpc.vpc_id

  tags = local.aws_tags
}

resource "aws_security_group_rule" "instance_eip" {
  for_each = module.ec2_instances.eips

  type        = "ingress"
  description = "Allow all ports from instance EIP ${each.key}"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${each.value.public_ip}/32"]

  security_group_id = aws_security_group.instance_eips.id
}

resource "aws_security_group" "bastion" {
  count = local.bastion_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-bastion"
  description = "Bastion ingress: SSH from internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "single_node" {
  count = local.single_node_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-single-node"
  description = "Single-node ingress: HTTP, HTTPS, 8448, and SSH (when no bastion)"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = local.gateway_needs_ssh ? [1] : []
    content {
      description = "SSH (no bastion present)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 8448"
    from_port   = 8448
    to_port     = 8448
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "gateway" {
  count = local.gateway_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-gateway"
  description = "Gateway ingress: HTTP, HTTPS, 8448, and SSH (when no bastion)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 8448"
    from_port   = 8448
    to_port     = 8448
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = local.gateway_needs_ssh ? [1] : []
    content {
      description = "SSH (no bastion present)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.aws_tags
}
