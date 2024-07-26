resource "aws_security_group" "bastion" {
  name        = "${var.aws_name_prefix}-bastion"
  description = "Bastion ingress rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "controller" {
  name        = "${var.aws_name_prefix}-controller"
  description = "Controller ingress rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Controller UI over HTTPS"
    from_port   = var.controller_ui_port
    to_port     = var.controller_ui_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Automation mesh"
    from_port   = "21799"
    to_port     = "21799"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "hub" {
  name        = "${var.aws_name_prefix}-hub"
  description = "Automation Hub ingress rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Hub UI over HTTPS"
    from_port   = var.hub_ui_port
    to_port     = var.hub_ui_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "eda" {
  name        = "${var.aws_name_prefix}-eda"
  description = "EDA ingress rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "EDA UI over HTTPS"
    from_port   = var.eda_ui_port
    to_port     = var.eda_ui_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "EDA Webhook ports"
    from_port   = var.eda_webhook_port_start
    to_port     = var.eda_webhook_port_end
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "gateway" {
  name        = "${var.aws_name_prefix}-gateway"
  description = "Automation Hub ingress rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Gateway UI over HTTPS"
    from_port   = var.gateway_ui_port
    to_port     = var.gateway_ui_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "single_node" {
  name        = "${var.aws_name_prefix}-single-node"
  description = "Additional ingress rules for single node AAP deployments"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Controller UI on single node"
    from_port   = var.single_node_controller_port
    to_port     = var.single_node_controller_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Hub UI on single node"
    from_port   = var.single_node_hub_port
    to_port     = var.single_node_hub_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "EDA UI on single node"
    from_port   = var.single_node_eda_port
    to_port     = var.single_node_eda_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "EDA Webhook ports"
    from_port   = var.eda_webhook_port_start
    to_port     = var.eda_webhook_port_end
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Gateway UI on single node"
    from_port   = var.single_node_gateway_port
    to_port     = var.single_node_gateway_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

# single_node_eips security group created separately to avoid circular dependencies
resource "aws_security_group" "single_node_eips" {
  name        = "${var.aws_name_prefix}-single-node-eips"
  description = "Ingress rules from single node EIPs"
  vpc_id      = module.vpc.vpc_id

  tags = local.aws_tags
}

# single_node_eips rules created separately to avoid circular dependencies
resource "aws_security_group_rule" "single_node_eips" {
  count = var.deploy_single_node ? var.single_node_instance_count : 0

  type        = "ingress"
  description = "PostgreSQL from AAP EIPs"
  from_port   = "5432"
  to_port     = "5432"
  protocol    = "tcp"
  cidr_blocks = ["${aws_eip.single_node[count.index].public_ip}/32"]

  security_group_id = aws_security_group.single_node_eips.id
}

resource "aws_security_group" "public_subnets" {
  name        = "${var.aws_name_prefix}-public-subnets"
  description = "Ingress rules for intra-VPC connections between public subnets"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  tags = local.aws_tags
}

resource "aws_security_group" "default_egress" {
  name        = "${var.aws_name_prefix}-default-egress"
  description = "Default egress rules for all instances"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}
