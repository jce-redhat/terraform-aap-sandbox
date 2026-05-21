# AWS-related variables
variable "aws_region" {
  description = "AWS region where resources are created"
  type        = string
  default     = "us-east-2"
}
variable "aws_num_azs" {
  description = "Number of availability zones to use for VPC subnets"
  type        = number
  # minimum two required for using RDS
  default = 2
}
variable "aws_name_prefix" {
  description = "Prefix used for AWS resource names"
  type        = string
  default     = "AAP-Sandbox"
}
variable "aws_vpc_cidr" {
  description = "CIDR used for the AWS VPC"
  type        = string
  default     = "172.23.0.0/16"
}
variable "aws_dns_zone" {
  description = "(Required) Base DNS zone for AAP records"
  type        = string
}
variable "aws_resource_owner" {
  description = "Value of the 'Owner' tag on AWS resources"
  type        = string
  default     = "AAP Sandbox User"
}
variable "aws_key_name" {
  description = "Name of the default EC2 key pair to create and associate with AWS instances"
  type        = string
  default     = "aap-sandbox-key"
}
variable "aws_key_content" {
  description = "(Required) SSH public key to use for the default EC2 key pair"
  type        = string
}
variable "aws_instance_type" {
  description = "Default EC2 instance type for AAP nodes"
  type        = string
  default     = "t3a.large"
}

# Instances configuration
variable "aap_instances" {
  description = "Map of AAP instances to create with their configurations"
  type = map(object({
    count                = number
    instance_type        = optional(string, "")
    disk_size            = optional(number, 0)
    key_name             = optional(string, "")
    image_id             = optional(string, "")
    node_os              = optional(string, "")
    arch                 = optional(string, "")
    name_prefix          = optional(string, "")
    security_groups      = optional(list(string), [])
    node_type            = string
    create_eip           = optional(bool, true)
    iam_instance_profile = optional(string, "")
  }))
  default = {
    aap = {
      count                = 1
      instance_type        = "t3a.xlarge"
      disk_size            = 60
      key_name             = ""
      image_id             = ""
      node_os              = ""
      arch                 = ""
      name_prefix          = ""
      security_groups      = []
      node_type            = "single-node"
      create_eip           = true
      iam_instance_profile = ""
    }
  }

  validation {
    condition = alltrue([
      for k, v in var.aap_instances : contains([
        "single-node",
        "gateway",
        "controller",
        "eda",
        "hub",
        "execution",
        "database",
        "dashboard",
        "bastion"
      ], v.node_type)
    ])
    error_message = "node_type must be one of: single-node, gateway, controller, eda, hub, execution, database, dashboard, bastion"
  }

  validation {
    condition = alltrue([
      for k, v in var.aap_instances :
      v.node_os == "" || contains(["rhel8", "rhel9", "rhel10"], v.node_os)
    ])
    error_message = "node_os must be empty or one of: rhel8, rhel9, rhel10"
  }

  validation {
    condition = alltrue([
      for k, v in var.aap_instances :
      v.arch == "" || contains(["x86_64", "arm64"], v.arch)
    ])
    error_message = "arch must be empty or one of: x86_64, arm64"
  }
}

variable "other_instances" {
  description = "Map of arbitrary instances to create (third-party integration nodes, etc.) - no node_type restrictions"
  type = map(object({
    count                = number
    instance_type        = optional(string, "")
    disk_size            = optional(number, 0)
    key_name             = optional(string, "")
    image_id             = optional(string, "")
    node_os              = optional(string, "")
    arch                 = optional(string, "")
    name_prefix          = optional(string, "")
    security_groups      = optional(list(string), [])
    node_type            = string
    create_eip           = optional(bool, true)
    iam_instance_profile = optional(string, "")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.other_instances :
      v.node_os == "" || contains(["rhel8", "rhel9", "rhel10"], v.node_os)
    ])
    error_message = "node_os must be empty or one of: rhel8, rhel9, rhel10"
  }

  validation {
    condition = alltrue([
      for k, v in var.other_instances :
      v.arch == "" || contains(["x86_64", "arm64"], v.arch)
    ])
    error_message = "arch must be empty or one of: x86_64, arm64"
  }

  validation {
    condition = alltrue([
      for k, v in var.other_instances :
      v.name_prefix != ""
    ])
    error_message = "name_prefix is required for all instances in other_instances map"
  }
}

# deployment options (legacy flags for integrations - to be refactored in future phases)
variable "deploy_with_rds" {
  description = "Deploy an RDS PostgreSQL database"
  type        = bool
  default     = false
}
variable "deploy_with_nlb" {
  description = "Deploy an Elastic Load Balancer in network mode"
  type        = bool
  default     = false
}
variable "create_instance_profile" {
  description = "Create a instance profile with an EC2 read-only role attached"
  type        = bool
  default     = false
}

# AMI-related variables
variable "rhel9_ami_name" {
  description = "Search string for RHEL 9 AMI"
  type        = string
  default     = "RHEL-9.4*Hourly*"
}
variable "rhel8_ami_name" {
  description = "Search string for RHEL 8 AMI"
  type        = string
  default     = "RHEL-8.10*Hourly*"
}
variable "rhel10_ami_name" {
  description = "Search string for RHEL 10 AMI"
  type        = string
  default     = "RHEL-10*Hourly*"
}

# Gateway LB variables (legacy - to be refactored in future phase)
variable "gateway_lb_name" {
  description = "The gateway LB name (used as the hostname)"
  type        = string
  default     = "aap"
}

# RDS-related variables (legacy - to be refactored in future phase)
variable "rds_instance_type" {
  description = "RDS Instance type for database"
  type        = string
  default     = "db.t3.small"
}
variable "rds_storage_gb" {
  description = "Storage in GB to allocate to the RDS instance"
  type        = number
  default     = 10
}
variable "rds_engine" {
  description = "RDS engine"
  type        = string
  default     = "postgres"
}
variable "rds_db_family" {
  description = "Database family for RDS DB family parameter"
  type        = string
  default     = "postgres15"
}
variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.17"
}
variable "rds_multi_az" {
  description = "Create a multi-AZ RDS deployment"
  type        = bool
  default     = false
}
variable "rds_username" {
  description = "Name of the root database user"
  type        = string
  default     = "postgres"
}
variable "rds_password" {
  description = <<EOF
    (Required) Password for the root database user

    To prevent storing the password in plaintext in the terraform.tfvars file,
    setting the TF_VAR_rds_password variable is recommended instead.
  EOF
  type        = string
  default     = ""
  sensitive   = true
}
