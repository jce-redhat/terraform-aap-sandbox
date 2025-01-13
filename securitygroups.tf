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
    from_port   = "27199"
    to_port     = "27199"
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
    description = "Gateway UI proxy on single node"
    from_port   = var.single_node_gateway_proxy_port
    to_port     = var.single_node_gateway_proxy_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "execution" {
  name        = "${var.aws_name_prefix}-execution"
  description = "Execution node ingress rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Automation mesh"
    from_port   = "27199"
    to_port     = "27199"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

# separate security group definition from rules definitions to work around
# lifecycle dependency issues
resource "aws_security_group" "aap_eips" {
  name        = "${var.aws_name_prefix}-aap_eips"
  description = "Communication between all AAP Elastic IPs"
  vpc_id      = module.vpc.vpc_id

  tags = local.aws_tags
}

resource "aws_security_group_rule" "single_node_eip" {
  count       = var.deploy_single_node ? var.single_node_instance_count : 0
  type        = "ingress"
  description = "Allow all ports from a single node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.single_node[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
}

resource "aws_security_group_rule" "controller_eip" {
  count       = var.deploy_single_node ? 0 : var.controller_instance_count
  type        = "ingress"
  description = "Allow all ports from a controller node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.controller[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
}

resource "aws_security_group_rule" "hub_eip" {
  count       = var.deploy_single_node ? 0 : var.hub_instance_count
  type        = "ingress"
  description = "Allow all ports from a hub node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.hub[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
}

resource "aws_security_group_rule" "eda_eip" {
  count       = var.deploy_single_node ? 0 : var.eda_instance_count
  type        = "ingress"
  description = "Allow all ports from an EDA node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.eda[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
}

resource "aws_security_group_rule" "gateway_eip" {
  count       = var.deploy_single_node ? 0 : var.gateway_instance_count
  type        = "ingress"
  description = "Allow all ports from a gateway node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.gateway[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
}

resource "aws_security_group_rule" "database_eip" {
  count       = var.deploy_single_node ? 0 : var.database_instance_count
  type        = "ingress"
  description = "Allow all ports from a database node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.database[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
}

resource "aws_security_group_rule" "execution_eip" {
  count       = var.deploy_single_node ? 0 : var.execution_instance_count
  type        = "ingress"
  description = "Allow all ports from an execution node EIP"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["${aws_eip.execution[count.index].public_ip}/32"]

  security_group_id = aws_security_group.aap_eips.id
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
