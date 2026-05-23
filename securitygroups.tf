locals {
  # AAP node types (only supported in aap_instances)
  bastion_count = try(sum([
    for k, v in var.aap_instances : v.count if v.node_type == "bastion"
  ]), 0)

  gateway_count = try(sum([
    for k, v in var.aap_instances : v.count if v.node_type == "gateway"
  ]), 0)

  single_node_count = try(sum([
    for k, v in var.aap_instances : v.count if v.node_type == "single-node"
  ]), 0)

  # Integration node types (only supported in other_instances)
  splunk_count = try(sum([
    for k, v in var.other_instances : v.count if v.node_type == "splunk"
  ]), 0)

  hashivault_count = try(sum([
    for k, v in var.other_instances : v.count if v.node_type == "hashivault"
  ]), 0)

  idm_count = try(sum([
    for k, v in var.other_instances : v.count if v.node_type == "idm"
  ]), 0)

  keycloak_count = try(sum([
    for k, v in var.other_instances : v.count if v.node_type == "keycloak"
  ]), 0)

  mattermost_count = try(sum([
    for k, v in var.other_instances : v.count if v.node_type == "mattermost"
  ]), 0)

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
    "splunk" = concat(
      ["base", "instance_eips"],
      local.splunk_count > 0 ? ["splunk"] : []
    )
    "hashivault" = concat(
      ["base", "instance_eips"],
      local.hashivault_count > 0 ? ["hashivault"] : []
    )
    "idm" = concat(
      ["base", "instance_eips"],
      local.idm_count > 0 ? ["idm"] : []
    )
    "keycloak" = concat(
      ["base", "instance_eips"],
      local.keycloak_count > 0 ? ["keycloak"] : []
    )
    "mattermost" = concat(
      ["base", "instance_eips"],
      local.mattermost_count > 0 ? ["mattermost"] : []
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

resource "aws_security_group" "splunk" {
  count = local.splunk_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-splunk"
  description = "Splunk ingress: HTTPS, forwarder, management, HEC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Splunk forwarder receiving"
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Splunk management port"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Event Collector (HEC)"
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "hashivault" {
  count = local.hashivault_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-hashivault"
  description = "HashiCorp Vault ingress: API/UI"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Vault API/UI"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "idm" {
  count = local.idm_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-idm"
  description = "Red Hat Identity Management ingress: Web UI, LDAP, Kerberos, DNS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS (Web UI)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos (TCP)"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos (UDP)"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos password change (TCP)"
    from_port   = 464
    to_port     = 464
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos password change (UDP)"
    from_port   = 464
    to_port     = 464
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS (TCP)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "keycloak" {
  count = local.keycloak_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-keycloak"
  description = "Keycloak ingress: HTTP and HTTPS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS (standard)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS (Keycloak default)"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}

resource "aws_security_group" "mattermost" {
  count = local.mattermost_count > 0 ? 1 : 0

  name        = "${var.aws_name_prefix}-mattermost"
  description = "Mattermost ingress: HTTPS and Mattermost server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Mattermost server"
    from_port   = 8065
    to_port     = 8065
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.aws_tags
}
