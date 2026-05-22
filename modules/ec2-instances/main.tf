locals {
  # Default name prefixes for each node type
  default_name_prefixes = {
    "single-node" = "aap"
    "gateway"     = "aap"
    "controller"  = "controller"
    "hub"         = "hub"
    "eda"         = "eda"
    "execution"   = "en"
    "database"    = "db"
    "dashboard"   = "dashboard"
    "bastion"     = "bastion"
  }

  # Flatten instances map to individual instances
  instances_flat = flatten([
    for instance_key, config in var.ec2_instances : [
      for i in range(config.count) : {
        # Unique key for for_each
        key = "${instance_key}-${i}"

        # Use name_prefix if provided, otherwise use default from node_type
        prefix = config.name_prefix != "" ? config.name_prefix : local.default_name_prefixes[config.node_type]

        # DNS-friendly name (single: "aap", multiple: "aap0", "aap1")
        name = config.count == 1 ? (
          config.name_prefix != "" ? config.name_prefix : local.default_name_prefixes[config.node_type]
          ) : (
          "${config.name_prefix != "" ? config.name_prefix : local.default_name_prefixes[config.node_type]}${i}"
        )

        # Instance configuration
        instance_key  = instance_key
        instance_type = config.instance_type != "" ? config.instance_type : var.instance_type
        disk_size     = config.disk_size != 0 ? config.disk_size : var.disk_size
        key_name      = config.key_name != "" ? config.key_name : var.key_name
        # AMI selection priority: image_id > ami_ids[node_os-arch] > ami_ids[rhel9-arch]
        # This respects the arch field even when node_os is not specified
        ami                  = config.image_id != "" ? config.image_id : var.ami_ids["${config.node_os != "" ? config.node_os : "rhel9"}-${config.arch != "" ? config.arch : var.arch}"]
        security_groups      = config.security_groups
        node_type            = config.node_type
        create_eip           = config.create_eip
        iam_instance_profile = config.iam_instance_profile
        subnet_id            = var.subnet_id
        tags                 = var.tags
      }
    ]
  ])

  # Convert to map for for_each
  instances_map = {
    for instance in local.instances_flat : instance.key => instance
  }
}

resource "aws_instance" "aap" {
  for_each = local.instances_map

  instance_type        = each.value.instance_type
  ami                  = each.value.ami
  key_name             = each.value.key_name
  subnet_id            = each.value.subnet_id
  iam_instance_profile = each.value.iam_instance_profile != "" ? each.value.iam_instance_profile : null

  vpc_security_group_ids = [
    for sg_name in each.value.security_groups : var.security_group_ids[sg_name]
  ]

  root_block_device {
    volume_size = each.value.disk_size
  }

  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(each.value.tags, {
    Name        = each.value.name
    NodeType    = each.value.node_type
    InstanceKey = each.value.instance_key
  })
}

resource "aws_eip" "aap" {
  for_each = {
    for k, v in local.instances_map : k => v if v.create_eip
  }

  instance = aws_instance.aap[each.key].id
  domain   = "vpc"

  tags = merge(each.value.tags, {
    Name = "${each.value.name}-eip"
  })
}
