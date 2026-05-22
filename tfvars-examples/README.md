# Terraform Variables Examples

Example `terraform.tfvars` files for AAP deployment topologies using the `aap_instances` map configuration.

## Available Examples

- **container-growth-topology.tfvars** - Single containerized AAP instance (uses defaults)
- **container-enterprise-topology.tfvars** - Multi-node with gateway, controller, hub, EDA, execution nodes, RDS, NLB
- **rpm-growth-topology.tfvars** - Traditional RPM deployment with separate database instance
- **single-node-arm-with-vault.tfvars** - ARM-based single-node AAP (RHEL 10, 120GB) with x86_64 Vault instance
- **other-instances-only.tfvars** - Non-AAP instances only (Splunk, Prometheus) with no AAP deployment

## Quick Start

1. Copy an example: `cp tfvars-examples/container-growth-topology.tfvars terraform.tfvars`
2. Edit mandatory variables: `aws_dns_zone` and `aws_key_content`
3. Deploy: `terraform init && terraform apply`

## Configuration

All examples use the `aap_instances` map. Most fields are optional with sensible defaults.

### Minimal (Single-Node)
```hcl
# No aap_instances block needed - creates 1x t3a.xlarge single-node instance
```

### Multi-Node
```hcl
aap_instances = {
  gateway    = { count = 2, node_type = "gateway" }
  controller = { count = 2, node_type = "controller" }
  hub        = { count = 2, node_type = "hub" }
}
```

### All Fields
```hcl
aap_instances = {
  aap = {
    count                = 1                # Required
    node_type            = "single-node"    # Required
    instance_type        = "t3a.xlarge"     # Optional: default t3a.large (t3a.xlarge for single-node)
    disk_size            = 60               # Optional: default 60 GB
    key_name             = ""               # Optional: uses aws_key_name
    image_id             = ""               # Optional: uses discovered RHEL 9 AMI
    node_os              = ""               # Optional: rhel8, rhel9, rhel10 (default rhel9)
    arch                 = ""               # Optional: x86_64, arm64 (default x86_64)
    name_prefix          = ""               # Optional: auto-assigned from node_type
    security_groups      = []               # Optional: auto-assigned from node_type
    create_eip           = true             # Optional: default true
    iam_instance_profile = ""               # Optional: default none
  }
}
```

## Instance Fields

| Field | Type | Required | Description | Default |
|-------|------|----------|-------------|---------|
| count | number | **Yes** | Number of instances | - |
| node_type | string | **Yes** | Component type (see Node Types) | - |
| instance_type | string | No | EC2 instance type | `t3a.large` (`t3a.xlarge` for single-node) |
| disk_size | number | No | Root volume GB | 60 |
| key_name | string | No | SSH key name | `aws_key_name` |
| image_id | string | No | Specific AMI ID | Discovered RHEL 9 AMI |
| node_os | string | No | RHEL version: rhel8, rhel9, rhel10 | `rhel9` |
| arch | string | No | CPU architecture: x86_64, arm64 | `x86_64` |
| name_prefix | string | No | Instance name prefix | Auto-assigned from `node_type` |
| security_groups | list(string) | No | Additional security groups | `[]` (auto-assigned) |
| create_eip | bool | No | Create Elastic IP | `true` |
| iam_instance_profile | string | No | IAM instance profile | None |

## Security Groups

Security groups auto-assign based on `node_type`. Specify `security_groups` only to add custom groups.

**All instances get:**
- **base** - VPC internal + internet egress
- **instance_eips** - Inter-instance EIP communication

**Node-type-specific:**
- **single-node**: `single_node` (HTTP, HTTPS, 8448, conditional SSH)
- **gateway**: `gateway` (HTTP, HTTPS, 8448, conditional SSH)
- **bastion**: `bastion` (SSH only)
- **All others**: base + instance_eips only

**Conditional SSH:** SSH auto-enables on single-node/gateway when no bastion exists. Adding a bastion removes SSH from single-node/gateway.

**Custom groups:**
```hcl
aap_instances = {
  aap = {
    count           = 1
    node_type       = "single-node"
    security_groups = ["my-custom-sg"]  # Merged with auto-assigned groups
  }
}
```

## Naming

**Auto-assigned prefixes** (when `name_prefix` is empty):

| node_type | prefix | Example (count=1) | Example (count=2) |
|-----------|--------|-------------------|-------------------|
| single-node | aap | aap | aap0, aap1 |
| gateway | aap | aap | aap0, aap1 |
| controller | controller | controller | controller0, controller1 |
| hub | hub | hub | hub0, hub1 |
| eda | eda | eda | eda0, eda1 |
| execution | en | en | en0, en1 |
| database | db | db | db0, db1 |
| dashboard | dashboard | dashboard | dashboard0, dashboard1 |
| bastion | bastion | bastion | bastion0, bastion1 |

Names appear in EC2 tags, DNS records (e.g., `aap.yourzone.com`, `controller0.yourzone.com`), and resource keys.

## Examples

**Single Node:**
```bash
cp tfvars-examples/container-growth-topology.tfvars terraform.tfvars
# Creates 1x t3a.xlarge all-in-one containerized instance
```

**Container Enterprise:**
```bash
cp tfvars-examples/container-enterprise-topology.tfvars terraform.tfvars
# Creates 10 instances (2 gateway, 2 controller, 2 hub, 2 EDA, 2 execution) + NLB + RDS
```

**RPM Growth:**
```bash
cp tfvars-examples/rpm-growth-topology.tfvars terraform.tfvars
# Creates 6 instances (1 gateway, 1 controller, 1 hub, 1 EDA, 1 execution, 1 database)
```

## Optional Integrations

**Bastion:**
```hcl
aap_instances = {
  bastion = { count = 1, node_type = "bastion" }
}
```

**Network Load Balancer:**
```hcl
deploy_with_nlb = true
```

**RDS PostgreSQL:**
```hcl
deploy_with_rds = true
rds_password    = "secure_password"  # Or use: export TF_VAR_rds_password="..."
```

## Node Types

Valid `node_type` values:
- `single-node` - All-in-one containerized AAP
- `gateway` - Gateway component
- `controller` - Automation controller
- `hub` - Automation hub
- `eda` - Event-Driven Ansible
- `execution` - Execution nodes
- `database` - PostgreSQL database (RPM deployments)
- `dashboard` - Dashboard component
- `bastion` - SSH jump host

## AMI and Architecture

**Specific AMI:**
```hcl
aap_instances = {
  aap = {
    count    = 1
    image_id = "ami-0123456789abcdef0"
    node_type = "single-node"
  }
}
```

**RHEL version:**
```hcl
aap_instances = {
  aap = {
    count     = 1
    node_os   = "rhel8"  # or rhel9, rhel10
    node_type = "single-node"
  }
}
```

**CPU architecture (ARM):**
```hcl
aap_instances = {
  aap = {
    count         = 1
    instance_type = "t4g.xlarge"  # ARM instance type
    arch          = "arm64"
    node_type     = "single-node"
  }
}
```

**Mixed architectures:**
```hcl
aap_instances = {
  controller = { count = 2, node_type = "controller" }  # Uses default x86_64
  execution  = { count = 2, instance_type = "t4g.large", arch = "arm64", node_type = "execution" }
}
```

## Other Instances

For non-AAP instances (Splunk, monitoring, etc.), use `other_instances`:

```hcl
other_instances = {
  splunk = {
    count       = 1
    name_prefix = "splunk"  # Required for other_instances
    node_type   = "splunk"  # Can be any string
  }
}
```

Note: `name_prefix` is required for `other_instances` but optional for `aap_instances`.
