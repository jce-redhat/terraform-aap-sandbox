# EC2 Instances Module

This module creates and manages AWS EC2 instances and Elastic IPs using a flexible map-based configuration. While designed for Ansible Automation Platform (AAP) deployments, it can be used for any type of EC2 instances in demo or sandbox environments.

## Purpose

Provides a unified, modular approach to creating multiple EC2 instances of any type using a map-based configuration instead of individual variables per instance type. Originally built for AAP components (controller, hub, EDA, gateway, execution nodes, etc.) but generic enough for arbitrary instance deployments.

## Key Features

- **Unified instance management**: Single resource definition for all instance types
- **Flexible configuration**: Map-based variable structure supports arbitrary instance types
- **Automatic naming**: Handles single vs multiple instance naming conventions
  - Single instance: uses `name_prefix` (e.g., "aap")
  - Multiple instances: appends index (e.g., "controller0", "controller1")
- **Optional Elastic IPs**: Configurable per instance type
- **Security group mapping**: Reference security groups by name
- **Component tagging**: Automatic tagging for instance organization
- **Smart defaults**: Automatic name prefix assignment based on component type

## Default Name Prefixes

The module automatically assigns name prefixes based on `node_type` when `name_prefix` is not explicitly provided:

| Node Type | Default Prefix | Example Names |
|----------------|----------------|---------------|
| `single-node`  | `aap`          | `aap` (single), `aap0`, `aap1` (multiple) |
| `gateway`      | `aap`          | `aap` (single), `aap0`, `aap1` (multiple) |
| `controller`   | `controller`   | `controller` (single), `controller0`, `controller1` |
| `hub`          | `hub`          | `hub` (single), `hub0`, `hub1` |
| `eda`          | `eda`          | `eda` (single), `eda0`, `eda1` |
| `execution`    | `en`           | `en` (single), `en0`, `en1` |
| `database`     | `db`           | `db` (single), `db0`, `db1` |
| `dashboard`    | `dashboard`    | `dashboard` (single), `dashboard0`, `dashboard1` |

You can override the default by explicitly setting `name_prefix` in your instance configuration.

## Usage

### Basic Example

```hcl
module "aap_instances" {
  source = "./modules/ec2-instances"

  aap_instances = {
    controller = {
      count                = 2
      instance_type        = "t3a.large"
      disk_size            = 60
      key_name             = ""
      image_id             = ""
      name_prefix          = "controller"
      security_groups      = ["controller", "aap_eips", "public_subnets", "default_egress"]
      node_type            = "controller"
      create_eip           = true
      iam_instance_profile = ""
    }
  }

  default_instance_type = "t3a.large"
  default_key_name      = "my-key"
  default_ami_id        = "ami-xxxxx"
  subnet_id             = "subnet-xxxxx"
  
  security_group_ids = {
    controller     = "sg-xxxxx"
    aap_eips       = "sg-xxxxx"
    public_subnets = "sg-xxxxx"
    default_egress = "sg-xxxxx"
  }

  tags = {
    Owner        = "Platform Team"
    DeploymentID = "abc123"
  }
}
```

### Single Node Example

```hcl
aap_instances = {
  aap = {
    count                = 1
    instance_type        = "t3a.xlarge"
    disk_size            = 60
    key_name             = ""
    image_id             = ""
    name_prefix          = "aap"
    security_groups      = ["controller", "single_node", "aap_eips", "default_egress"]
    node_type            = "single-node"
    create_eip           = true
    iam_instance_profile = ""
  }
}
```

## How It Works

### Instance Flattening Pattern

The module uses a "flattening" pattern to convert the map + count structure into individual instance resources:

1. **Input**: Map of instance types with counts
   ```hcl
   aap_instances = {
     controller = { count = 2, name_prefix = "controller", ... }
     hub = { count = 1, name_prefix = "hub", ... }
   }
   ```

2. **Flattening**: Expands each instance type into individual instances
   ```
   controller-0 (name: "controller0")
   controller-1 (name: "controller1")
   hub-0 (name: "hub")
   ```

3. **For_each**: Creates resources using flattened map keys
   ```hcl
   resource "aws_instance" "aap" {
     for_each = local.instances_map
     # ...
   }
   ```

This approach:
- Eliminates `count.index` references
- Maintains consistent naming across instances, EIPs, and DNS
- Enables easy cross-resource references by key
- Supports dynamic filtering and grouping

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| aap_instances | Map of AAP instances to create | map(object) | n/a | yes |
| default_instance_type | Default instance type when not specified | string | n/a | yes |
| default_key_name | Default SSH key when not specified | string | n/a | yes |
| default_ami_id | Default AMI ID when not specified | string | n/a | yes |
| default_disk_size | Default disk size in GB when not specified | number | 60 | no |
| subnet_id | Subnet ID for all instances | string | n/a | yes |
| security_group_ids | Map of security group names to IDs | map(string) | n/a | yes |
| tags | Common tags for all resources | map(string) | {} | no |

### Instance Object Structure

Each instance in the `aap_instances` map must have:

```hcl
{
  count                = number  # Number of instances to create
  instance_type        = string  # EC2 instance type (empty string uses default)
  disk_size            = number  # Root volume size in GB (0 uses default: 60)
  key_name             = string  # SSH key name (empty string uses default)
  image_id             = string  # AMI ID (empty string uses default)
  name_prefix          = string  # Name prefix (empty string uses node_type default)
  security_groups      = list(string)  # List of security group names
  node_type            = string  # Component type (see allowed values below)
  create_eip           = bool    # Whether to create an Elastic IP
  iam_instance_profile = string  # IAM instance profile name (empty string = none)
}
```

**Allowed `node_type` values:**
- `single-node` - Single-node AAP deployment
- `gateway` - AAP gateway component
- `controller` - Automation controller
- `eda` - Event-Driven Ansible
- `hub` - Automation hub
- `execution` - Execution nodes
- `database` - Dedicated PostgreSQL database
- `dashboard` - Automation dashboard

The variable includes validation to ensure `node_type` is one of these values.

## Outputs

| Name | Description |
|------|-------------|
| instances | Map of instance keys to instance details (id, IPs, name, type) |
| eips | Map of instance keys to Elastic IP addresses |
| instances_by_component | Map of node types to lists of instance keys |
| instance_names | Map of instance keys to DNS-friendly names |

### Output Usage

```hcl
# Reference specific instance
module.aap_instances.instances["controller-0"].id

# Get all EIP public IPs
values(module.aap_instances.eips)[*].public_ip

# Get instances by component type
module.aap_instances.instances_by_component["controller"]
```

## Requirements

- Terraform >= 1.5.0
- AWS Provider ~> 6.0

## Notes

- All instances are created with `associate_public_ip_address = true`
- IMDSv2 is enforced on all instances (`http_tokens = "required"`)
- Instances are tagged with Name, NodeType, and InstanceKey for organization
- Empty strings for instance_type, key_name, or image_id will use the default values
- Setting disk_size to 0 will use the default value (60 GB)
- Elastic IPs are only created when `create_eip = true`
- IAM instance profiles are only attached when iam_instance_profile is non-empty
