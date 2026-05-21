# Terraform Variables Examples

This directory contains example `terraform.tfvars` files for different AAP deployment topologies using the unified `aap_instances` map configuration.

## Available Examples

- **container-growth-topology.tfvars** - Single containerized AAP instance (growth topology) - uses defaults
- **container-enterprise-topology.tfvars** - Multi-node container deployment with gateway, controller, hub, EDA, execution nodes, RDS, and NLB
- **rpm-growth-topology.tfvars** - Traditional RPM-based deployment with separate database instance

## Quick Start

1. Copy an example file to the root directory:
   ```bash
   cp tfvars-examples/container-growth-topology.tfvars terraform.tfvars
   ```

2. Edit the mandatory variables:
   ```hcl
   aws_dns_zone    = "your-zone.example.com"
   aws_key_content = "ssh-ed25519 AAAA..."
   ```

3. Deploy:
   ```bash
   terraform init
   terraform apply
   ```

## Configuration Format

All examples use the unified `aap_instances` map for instance configuration. Most fields are optional and use sensible defaults:

### Minimal Configuration (Single-Node)
```hcl
# Uses all defaults - creates 1x single-node t3a.xlarge instance
# No aap_instances block needed - default is single-node deployment
```

### Multi-Node Configuration
```hcl
aap_instances = {
  gateway    = { count = 2, node_type = "gateway" }
  controller = { count = 2, node_type = "controller" }
  hub        = { count = 2, node_type = "hub" }
}
```

### Full Configuration Example (All Optional Fields)
```hcl
aap_instances = {
  aap = {
    count                = 1                # Required
    node_type            = "single-node"    # Required
    instance_type        = "t3a.xlarge"     # Optional: defaults to t3a.large
    disk_size            = 60               # Optional: defaults to 60 GB
    key_name             = ""               # Optional: uses aws_key_name
    image_id             = ""               # Optional: uses discovered RHEL 9 AMI
    node_os              = ""               # Optional: rhel8, rhel9, rhel10
    name_prefix          = ""               # Optional: auto-assigned from node_type
    security_groups      = []               # Optional: auto-assigned from node_type
    create_eip           = true             # Optional: defaults to true
    iam_instance_profile = ""               # Optional: set to use IAM profile
  }
}
```

## Instance Object Fields

| Field | Type | Required | Description | Default |
|-------|------|----------|-------------|---------|
| count | number | **Yes** | Number of instances to create | - |
| node_type | string | **Yes** | Component type (see Node Types below) | - |
| instance_type | string | No | EC2 instance type | `t3a.large` (or `t3a.xlarge` for single-node default) |
| disk_size | number | No | Root volume size in GB | 60 |
| key_name | string | No | SSH key name | Uses `aws_key_name` |
| image_id | string | No | Specific AMI ID to use | Uses discovered RHEL 9 AMI |
| node_os | string | No | RHEL version: rhel8, rhel9, rhel10 | Uses `image_id` if set, else RHEL 9 |
| name_prefix | string | No | Name prefix for instances | Auto-assigned from `node_type` |
| security_groups | list(string) | No | Additional security groups | `[]` (auto-assigned by node_type) |
| create_eip | bool | No | Whether to create Elastic IP | `true` |
| iam_instance_profile | string | No | IAM instance profile name | `""` (none) |

## Security Groups

Security groups are **automatically assigned** based on `node_type`. You don't need to specify them unless adding custom groups.

### Automatic Security Group Assignment

All instances automatically receive:
- **base** - VPC internal ingress + internet egress
- **instance_eips** - Communication between all instance Elastic IPs

Plus node-type-specific groups:
- **single-node** instances get: `single_node` (HTTP, HTTPS, 8448, conditional SSH)
- **gateway** instances get: `gateway` (HTTP, HTTPS, 8448, conditional SSH)
- **bastion** instances get: `bastion` (SSH only)
- **All other node types** get: only base + instance_eips

### Conditional SSH Access

- SSH is automatically enabled on **single-node** and **gateway** instances when no bastion exists
- If you add a bastion instance, SSH is removed from single-node/gateway and only allowed on bastion
- This happens automatically - no configuration needed

### Adding Custom Security Groups

To add extra security groups beyond the automatic defaults:

```hcl
aap_instances = {
  aap = {
    count           = 1
    node_type       = "single-node"
    security_groups = ["my-custom-sg"]  # Added to automatic defaults
  }
}
```

## Default Name Prefixes

When `name_prefix` is not specified, the module automatically assigns a prefix based on `node_type`:

| Node Type | Default Prefix |
|----------------|----------------|
| `single-node`  | `aap` |
| `gateway`      | `aap` |
| `controller`   | `controller` |
| `hub`          | `hub` |
| `eda`          | `eda` |
| `execution`    | `en` |
| `database`     | `db` |
| `dashboard`    | `dashboard` |
| `bastion`      | `bastion` |

You can override any default by explicitly setting `name_prefix` in your configuration.

## Instance Naming Convention

- **Single instance** (count = 1): Uses `name_prefix` directly (e.g., "aap", "bastion")
- **Multiple instances** (count > 1): Appends index to `name_prefix` (e.g., "controller0", "controller1")

This naming is automatically handled by the `ec2-instances` module and reflected in:
- EC2 instance Name tags
- DNS records (e.g., aap.yourzone.com, controller0.yourzone.com)
- Resource keys

## Example Configurations

### Single Node (Quick Demo)
```bash
cp tfvars-examples/container-growth-topology.tfvars terraform.tfvars
```
Creates one t3a.xlarge instance with all AAP components containerized. SSH enabled automatically.

### Container Enterprise (Multi-Node Eval)
```bash
cp tfvars-examples/container-enterprise-topology.tfvars terraform.tfvars
```
Creates 10 instances (2 gateway, 2 controller, 2 hub, 2 EDA, 2 execution) with NLB and RDS. SSH enabled on gateway nodes automatically.

### RPM Growth (Traditional Deployment)
```bash
cp tfvars-examples/rpm-growth-topology.tfvars terraform.tfvars
```
Creates 6 instances (1 gateway, 1 controller, 1 hub, 1 EDA, 1 execution, 1 database). SSH enabled on gateway automatically.

## Optional Integrations

### With Bastion/Jump Host

Add a bastion instance to any configuration:

```hcl
aap_instances = {
  # ... your other instances ...
  bastion = {
    count     = 1
    node_type = "bastion"
  }
}
```

When a bastion is present, SSH access is automatically removed from gateway and single-node instances and only allowed through the bastion.

### With Network Load Balancer

Add when deploying gateway instances:
```hcl
deploy_with_nlb = true
```

### With RDS PostgreSQL

Add for managed database:
```hcl
deploy_with_rds = true
rds_password    = "secure_password_here"
```

Or set via environment variable to avoid storing in plain text:
```bash
export TF_VAR_rds_password="secure_password_here"
```

## Node Types

Valid `node_type` values for `aap_instances`:

- `single-node` - All-in-one containerized AAP
- `gateway` - AAP gateway component
- `controller` - Automation controller
- `hub` - Automation hub
- `eda` - Event-Driven Ansible
- `execution` - Execution nodes
- `database` - Dedicated PostgreSQL database (for RPM deployments)
- `dashboard` - Dashboard component
- `bastion` - SSH jump/bastion host

## Using Specific AMI IDs

To use a specific AMI instead of the auto-discovered RHEL AMIs:

```hcl
aap_instances = {
  aap = {
    count    = 1
    image_id = "ami-0123456789abcdef0"  # Your specific AMI
    node_type = "single-node"
  }
}
```

Or to use a different RHEL version:

```hcl
aap_instances = {
  aap = {
    count     = 1
    node_os   = "rhel8"  # or "rhel9", "rhel10"
    node_type = "single-node"
  }
}
```

## Other Instances

For non-AAP instances (like Splunk, monitoring, etc.), use the `other_instances` map:

```hcl
other_instances = {
  splunk = {
    count       = 1
    name_prefix = "splunk"  # Required for other_instances
    node_type   = "splunk"  # Can be any string
  }
}
```

The `name_prefix` field is required for `other_instances` but not for `aap_instances`.
