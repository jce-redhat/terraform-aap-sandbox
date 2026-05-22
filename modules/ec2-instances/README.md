# ec2-instances

Creates EC2 instances and optional Elastic IPs from a map-based configuration. Built for Ansible Automation Platform deployments but works for any EC2 instances.

## Usage

```hcl
module "instances" {
  source = "./modules/ec2-instances"

  ec2_instances = {
    controller = {
      count           = 2
      instance_type   = "t3a.large"
      disk_size       = 100
      node_type       = "controller"
      security_groups = ["controller", "base"]
      create_eip      = true
    }
    hub = {
      count           = 1
      instance_type   = "t3a.medium"
      node_type       = "hub"
      node_os         = "rhel9"
      arch            = "arm64"
      security_groups = ["hub", "base"]
      create_eip      = false
    }
  }

  # AMI map: keyed by "<os>-<arch>" pattern
  ami_ids = {
    "rhel9-x86_64" = "ami-0123456789abcdef0"
    "rhel9-arm64"  = "ami-0fedcba9876543210"
  }

  # Module-level instance defaults
  instance_type = "t3a.small"
  key_name      = "my-key"
  arch          = "x86_64"
  disk_size     = 60

  # Shared across all instances
  subnet_id = "subnet-xxxxx"

  # Security group name-to-ID mapping
  security_group_ids = {
    base       = "sg-base"
    controller = "sg-controller"
    hub        = "sg-hub"
  }

  # Tags applied to all instances
  tags = {
    Environment = "sandbox"
  }
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ec2_instances` | map(object) | Yes | Map of instances to create (see Instance Object below) |
| `ami_ids` | map(string) | Yes | Map of AMI IDs keyed by "os-arch" (e.g., "rhel9-x86_64", "rhel9-arm64") |
| `instance_type` | string | Yes | Default instance type when not specified per instance |
| `key_name` | string | Yes | Default SSH key name when not specified per instance |
| `subnet_id` | string | Yes | Subnet ID for all instances |
| `security_group_ids` | map(string) | Yes | Map of security group names to IDs |
| `arch` | string | No | Default CPU architecture: "x86_64" or "arm64" (default: "x86_64") |
| `disk_size` | number | No | Default root disk size in GB (default: 60) |
| `tags` | map(string) | No | Common tags applied to all resources |

### Instance Object

Each instance in `ec2_instances` requires:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `count` | number | Yes | Number of instances to create |
| `node_type` | string | Yes | Component type (used for tagging and naming) |
| `instance_type` | string | No | EC2 instance type (empty string uses module default) |
| `disk_size` | number | No | Root volume GB (0 uses module default) |
| `key_name` | string | No | SSH key name (empty string uses module default) |
| `image_id` | string | No | Specific AMI ID (empty string uses ami_ids map) |
| `node_os` | string | No | OS version for AMI lookup: "rhel8", "rhel9", "rhel10" (empty string uses "rhel9") |
| `arch` | string | No | CPU architecture: "x86_64", "arm64" (empty string uses module default) |
| `name_prefix` | string | No | Name prefix (empty string auto-generates from node_type) |
| `security_groups` | list(string) | No | List of security group names from security_group_ids map |
| `create_eip` | bool | No | Create Elastic IP (default: true) |
| `iam_instance_profile` | string | No | IAM instance profile name (empty string = none) |

## Outputs

| Name | Description |
|------|-------------|
| `instances` | Map of instance keys to instance details (id, IPs, name, node_type) |
| `eips` | Map of instance keys to Elastic IP details |
| `instances_by_node_type` | Map of node_types to lists of instance keys |
| `instance_names` | Map of instance keys to DNS-friendly names |

## Behavior

**Defaults:** Module-level variables (`instance_type`, `key_name`, `arch`, `disk_size`) act as defaults when instance fields are empty or zero. Empty string (`""`) triggers the default; explicit values override it. This lets you set deployment-wide defaults while allowing per-instance customization.

**AMI Selection:** When `image_id` is empty, the module constructs a lookup key from `node_os` (defaults to "rhel9") and `arch` (defaults to module-level `arch`), then retrieves the AMI from the `ami_ids` map. Example: `node_os="rhel9"` + `arch="arm64"` → looks up `ami_ids["rhel9-arm64"]`.

**Instance Naming:**
- Single instance (count = 1): uses `name_prefix` directly
- Multiple instances (count > 1): appends index (e.g., "controller0", "controller1")

**Default Name Prefixes:** When `name_prefix` is empty, auto-assigned from `node_type`:

| node_type | prefix |
|-----------|--------|
| single-node | aap |
| gateway | aap |
| controller | controller |
| hub | hub |
| eda | eda |
| execution | en |
| database | db |
| dashboard | dashboard |
| bastion | bastion |

**Security Groups:** Instances reference security groups by name via the `security_groups` field. The module looks up each name in the `security_group_ids` map to get the actual AWS security group ID. Security groups are created outside the module to keep it generic—security rules are deployment-specific, while this module is reusable across different security architectures.

**Security:** All instances enforce IMDSv2 (`http_tokens = "required"`) and are created with public IPs.

**Tags:** Each instance receives `Name`, `NodeType`, `InstanceKey` tags plus any tags from the `tags` input.
