# terraform-aap-sandbox - Build AWS infrastructure for Ansible Automation Platform demos

Terraform configuration for building Ansible Automation Platform (AAP) infrastructure
in an AWS VPC.  Deployment options include:

* Creating one or more instances for single node deployments using the containerized AAP installer
* Creating one or more controller, hub, or EDA controller instances for a larger deployment
* Creating an RDS PostgreSQL instance to use as an external (non-managed) database

## Prerequisites

1. AWS access and secret keys with sufficient priviliges to create EC2 components (VPC networking,
   instances, security groups, key pairs) and Route53 DNS records.
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
   this file must contain the following variables (see [vars.tf](vars.tf)) for all available variables):
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
