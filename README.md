# terraform-aap-sandbox - Build AWS infrastructure for Ansible Automation Platform demos

Terraform configuration for building Ansible Automation Platform (AAP) infrastructure
in an AWS VPC using a map-based instance configuration. Supports single-node and multi-node
topologies with automatic security group assignment and per-instance architecture selection.
Deployment options include:

* Single-node or multi-node AAP deployments (gateway, controller, hub, EDA, execution nodes)
* Deploy x86_64, arm64, or a mix of instance architectures in the same deployment
* Optional RDS PostgreSQL database, Network Load Balancer, and bastion host
* Optional non-AAP instances for monitoring, integration tools, or other workloads

## Prerequisites

1. AWS access and secret keys with sufficient priviliges to create resources in various AWS
   services: EC2 (VPC, instances, security groups, key pairs, load balancers), Route53, and RDS.
2. An existing AWS Route53 hosted zone where records will be created.
3. A pre-existing SSH key pair.  An AWS key pair entry will be created using the existing public key.
4. The terraform binary (see [Install Terraform](https://developer.hashicorp.com/terraform/install)).

For Red Hatters, an open environment can be created on demo.redhat.com to fulfill the first two requirements.

## Quick Start

1. Clone this repo and `cd` into the local repo directory.
```
git clone https://github.com/jce-redhat/terraform-aap-sandbox.git
cd terraform-aap-sandbox
```
2. Initialize terraform.  The terraform state will be kept locally in the cloned repo directory.
```
terraform init
```
3. Create a terraform.tfvars file that set the variables appropriate to your deployment.  At a minimum
   this file must contain the following variables (see [vars.tf](vars.tf)) for all available variables).
   Example terraform.tfvars files can be found in the [tfvars-examples directory](tfvars-examples).
```
aws_dns_zone    = "<your_route53_zone>"
aws_key_content = "<your_public_key>"
```
4. Set the AWS access and secret key environment variables.
```
export AWS_ACCESS_KEY_ID=<your_access_key>
export AWS_SECRET_ACCESS_KEY=<your_secret_key>
```
5. Run terraform to create the AWS resources.
```
terraform apply
```

## Features

**Instance Configuration:**
* Unified `aap_instances` map for all AAP components (single-node, gateway, controller, hub, EDA, execution, database, dashboard, bastion)
* `other_instances` map for non-AAP workloads (monitoring, integration tools, etc.)
* Per-instance CPU architecture selection (x86_64, arm64) for mixed deployments
* Automatic instance naming and DNS record creation

**Security:**
* Automatic security group assignment based on node type
* Conditional SSH access - auto-enables on gateway/single-node instances when no bastion exists
* IMDSv2 enforced on all instances

**Tested Deployment Topologies:**
* Single-node containerized AAP (growth topology)
* Multi-node container deployment with gateway, controller, hub, EDA, and execution nodes
* RPM-based deployment with dedicated database instance
* Non-AAP instances only (no AAP deployment)

**Optional Integrations:**
* RDS PostgreSQL for managed external database
* Network Load Balancer for gateway instances
* Bastion/jump host with automatic SSH rule adjustments
* IAM instance profiles for EC2 instances
