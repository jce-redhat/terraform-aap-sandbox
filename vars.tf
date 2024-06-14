# AWS-related variables
variable "aws_region" {
  description = "AWS region where resources are created"
  type        = string
  default     = "us-west-2"
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
  description = "Base DNS zone for AAP records"
  type        = string
}
variable "aws_resource_owner" {
  description = "String used for 'Owner' tag on AWS resources"
  type        = string
  default     = "John Q Citizen"
}
variable "aws_key_name" {
  description = "SSH key pair to associate with AWS instances"
  type        = string
  default     = "aap-sandbox-key"
}
variable "aws_key_content" {
  description = "SSH public key to use for the sandbox key pair"
  type        = string
}

# deployment options
variable "deploy_single_node" {
  description = "Deploy a single node for containerized AAP"
  type        = bool
  default     = false
}
variable "deploy_with_rds" {
  description = "Deploy an RDS PostgreSQL database"
  type        = bool
  default     = false
}
variable "deploy_bastion" {
  description = "Deploy an instance to use as a bastion host"
  type        = bool
  default     = false
}
variable "deploy_with_rhel8" {
  description = "Deploy with RHEL 8 AMIs (otherwise use RHEL 9)"
  type        = bool
  default     = false
}

# AMI-related variables
variable "rhel9_ami_name" {
  description = "Search string for RHEL 9 AMI"
  type        = string
  default     = "RHEL-9.2*Hourly*"
}
variable "rhel8_ami_name" {
  description = "Search string for RHEL 8 AMI"
  type        = string
  default     = "RHEL-8.8*Hourly*"
}
variable "rhel_arch" {
  description = "CPU architecture to use for RHEL AMI"
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.rhel_arch)
    error_message = "Valid values are 'x86_64' or 'arm64'"
  }
}

# single-node AAP variables
variable "single_node_instance_count" {
  description = "The number of single-node instances to create"
  type        = number
  default     = 1
}
variable "single_node_instance_type" {
  description = "The instance type used for the AIO instance"
  type        = string
  default     = "t3a.xlarge"
}
variable "single_node_image_id" {
  description = "The AMI ID used for the AIO instance"
  type        = string
  default     = ""
}
variable "single_node_key_name" {
  description = "Key pair name associated with AIO instance"
  type        = string
  default     = ""
}
variable "single_node_disk_size" {
  description = "The volume size used for the AIO instance"
  type        = number
  default     = 40
}
variable "single_node_instance_name" {
  description = "The 'Name' tag applied to the AIO instance"
  type        = string
  default     = "aap"
}
variable "single_node_controller_port" {
  description = "The port used by Controller on single node deployments"
  type        = string
  default     = "8443"
}
variable "single_node_hub_port" {
  description = "The port used by Hub on single node deployments"
  type        = string
  default     = "8444"
}
variable "single_node_eda_port" {
  description = "The port used by EDA on single node deployments"
  type        = string
  default     = "8445"
}

# Bastion variables
variable "bastion_instance_type" {
  description = "The instance type used for the bastion(s)"
  type        = string
  default     = "t3a.small"
}
variable "bastion_image_id" {
  description = "The AMI ID used for the bastion"
  type        = string
  default     = ""
}
variable "bastion_key_name" {
  description = "Key pair name associated with the bastion"
  type        = string
  default     = ""
}
variable "bastion_disk_size" {
  description = "The volume size used for the bastion"
  type        = number
  default     = 15
}
variable "bastion_instance_name" {
  description = "The 'Name' tag applied to the bastion"
  type        = string
  default     = "bastion"
}

# Controller variables
variable "controller_instance_count" {
  description = "The number of controller instances to create"
  type        = number
  default     = 1
}
variable "controller_instance_type" {
  description = "The instance type used for the controller(s)"
  type        = string
  default     = "t3a.large"
}
variable "controller_image_id" {
  description = "The AMI ID used for the controller(s)"
  type        = string
  default     = ""
}
variable "controller_key_name" {
  description = "Key pair name associated with the controller"
  type        = string
  default     = ""
}
variable "controller_disk_size" {
  description = "The volume size used for the controller(s)"
  type        = number
  default     = 40
}
variable "controller_instance_name" {
  description = "The 'Name' tag applied to the controller(s)"
  type        = string
  default     = "controller"
}
variable "controller_ui_port" {
  description = "The Controller UI port"
  type        = string
  default     = "443"
}

# Hub variables
variable "hub_instance_count" {
  description = "The number of Hub instances to create"
  type        = number
  default     = 1
}
variable "hub_instance_type" {
  description = "The instance type used for the hub(s)"
  type        = string
  default     = "t3a.large"
}
variable "hub_image_id" {
  description = "The AMI ID used for the hub(s)"
  type        = string
  default     = ""
}
variable "hub_key_name" {
  description = "Key pair name associated with the hub"
  type        = string
  default     = ""
}
variable "hub_disk_size" {
  description = "The volume size used for the hub(s)"
  type        = number
  default     = 40
}
variable "hub_instance_name" {
  description = "The 'Name' tag applied to the hub(s)"
  type        = string
  default     = "hub"
}
variable "hub_ui_port" {
  description = "The Hub UI port"
  type        = string
  default     = "443"
}

# EDA variables
variable "eda_instance_count" {
  description = "The number of EDA instances to create"
  type        = number
  default     = 1
}
variable "eda_instance_type" {
  description = "The instance type used for the EDA node(s)"
  type        = string
  default     = "t3a.large"
}
variable "eda_image_id" {
  description = "The AMI ID used for the EDA node(s)"
  type        = string
  default     = ""
}
variable "eda_key_name" {
  description = "Key pair name associated with the EDA node(s)"
  type        = string
  default     = ""
}
variable "eda_disk_size" {
  description = "The volume size used for the EDA node(s)"
  type        = number
  default     = 40
}
variable "eda_instance_name" {
  description = "The 'Name' tag applied to the EDA node(s)"
  type        = string
  default     = "eda"
}
variable "eda_webhook_port_start" {
  description = "Starting port number for EDA webhooks"
  type        = string
  default     = "5000"
}
variable "eda_webhook_port_end" {
  description = "Ending port number for EDA webhooks"
  type        = string
  default     = "5010"
}
variable "eda_ui_port" {
  description = "The EDA UI port"
  type        = string
  default     = "443"
}

# RDS-related variables
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
variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "13.13"
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
  description = "Password for the root database user"
  type        = string
  default     = ""
  sensitive   = true
}
