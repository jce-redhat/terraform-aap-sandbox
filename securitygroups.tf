resource "aws_security_group" "ssh" {
  name        = "${var.aws_name_prefix}-ssh"
  description = "SSH (22/tcp) global ingress"
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

resource "aws_security_group" "https" {
  name        = "${var.aws_name_prefix}-https"
  description = "HTTPS (443/tcp) global ingress"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "automation_mesh" {
  name        = "${var.aws_name_prefix}-automation-mesh"
  description = "AAP automation mesh (21799/tcp) global ingress"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Automation mesh"
    from_port   = "21799"
    to_port     = "21799"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "eda_webhooks" {
  name        = "${var.aws_name_prefix}-eda-webhooks"
  description = "Global ingress for EDA webhook ports"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "EDA Webhook ports"
    from_port   = var.eda_webhook_port_start
    to_port     = var.eda_webhook_port_end
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "single_node_hub" {
  name        = "${var.aws_name_prefix}-single-node-hub"
  description = "Global ingress for Hub UI port on single-node deployments"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Hub UI on single node"
    from_port   = var.single_node_hub_port
    to_port     = var.single_node_hub_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "single_node_eda" {
  name        = "${var.aws_name_prefix}-single-node-eda"
  description = "Global ingress for EDA UI port on single-node deployments"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Hub UI on single node"
    from_port   = var.single_node_eda_port
    to_port     = var.single_node_eda_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
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

  tags = {
    Owner = var.aws_resource_owner
  }
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

  tags = {
    Owner = var.aws_resource_owner
  }
}
