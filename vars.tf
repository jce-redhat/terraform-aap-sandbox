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
  description = "(Required) Base DNS zone for AAP records"
  type        = string
}
variable "aws_resource_owner" {
  description = "Value of the 'Owner' tag on AWS resources"
  type        = string
  default     = "AAP-Sandbox User"
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

# deployment options
variable "deploy_single_node" {
  description = "Deploy a single node for containerized AAP"
  type        = bool
  default     = false
}
variable "deploy_database_node" {
  description = "Deploy a database node"
  type        = bool
  default     = false
}
variable "deploy_with_rds" {
  description = "Deploy an RDS PostgreSQL database"
  type        = bool
  default     = false
}
variable "deploy_bastion" {
  description = "Deploy an instance to use as a bastion or installation host"
  type        = bool
  default     = false
}
variable "deploy_dashboard" {
  description = "Deploy an instance to use as the automation dashboard host"
  type        = bool
  default     = false
}
variable "deploy_with_rhel8" {
  description = "Deploy with RHEL 8 AMIs (otherwise use RHEL 9)"
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
  description = <<EOF
    The number of single-node instances to create when the
    deploy_single_node variable is set to "true"
  EOF
  type        = number
  default     = 1
}
variable "single_node_instance_type" {
  description = "The instance type used for the single-node instance"
  type        = string
  default     = "t3a.xlarge"
}
variable "single_node_image_id" {
  description = "The AMI ID used for the single-node instance"
  type        = string
  default     = ""
}
variable "single_node_key_name" {
  description = "EC2 key pair associated with the single-node instance"
  type        = string
  default     = ""
}
variable "single_node_disk_size" {
  description = "The volume size in GB used for the single-node instance"
  type        = number
  default     = 60
}
variable "single_node_instance_name" {
  description = "The 'Name' tag applied to the single-node instance"
  type        = string
  default     = "aap"
}
variable "single_node_controller_port" {
  description = "The port used by Controller on single-node deployments"
  type        = string
  default     = "8443"
}
variable "single_node_hub_port" {
  description = "The port used by Hub on single-node deployments"
  type        = string
  default     = "8444"
}
variable "single_node_eda_port" {
  description = "The port used by EDA on single-node deployments"
  type        = string
  default     = "8445"
}
variable "single_node_gateway_proxy_port" {
  description = "The port used by Gateway envoy proxy on single-node deployments"
  type        = string
  default     = "443"
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
  description = "EC2 key pair associated with the bastion instance"
  type        = string
  default     = ""
}
variable "bastion_disk_size" {
  description = "The volume size in GB used for the bastion"
  type        = number
  default     = 40
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
  default     = ""
}
variable "controller_image_id" {
  description = "The AMI ID used for the controller(s)"
  type        = string
  default     = ""
}
variable "controller_key_name" {
  description = "EC2 key pair associated with the controller instance"
  type        = string
  default     = ""
}
variable "controller_disk_size" {
  description = "The volume size in GB used for the controller(s)"
  type        = number
  default     = 60
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
  default     = ""
}
variable "hub_image_id" {
  description = "The AMI ID used for the hub(s)"
  type        = string
  default     = ""
}
variable "hub_key_name" {
  description = "EC2 key pair associated with the hub instance"
  type        = string
  default     = ""
}
variable "hub_disk_size" {
  description = "The volume size in GB used for the hub(s)"
  type        = number
  default     = 60
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
  default     = ""
}
variable "eda_image_id" {
  description = "The AMI ID used for the EDA node(s)"
  type        = string
  default     = ""
}
variable "eda_key_name" {
  description = "EC2 key pair associated with the EDA instance"
  type        = string
  default     = ""
}
variable "eda_disk_size" {
  description = "The volume size in GB used for the EDA node(s)"
  type        = number
  default     = 60
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

# Gateway variables
variable "gateway_instance_count" {
  description = "The number of gateway instances to create"
  type        = number
  default     = 1
}
variable "gateway_instance_type" {
  description = "The instance type used for the gateway(s)"
  type        = string
  default     = ""
}
variable "gateway_image_id" {
  description = "The AMI ID used for the gateway(s)"
  type        = string
  default     = ""
}
variable "gateway_key_name" {
  description = "EC2 key pair associated with the gateway instance"
  type        = string
  default     = ""
}
variable "gateway_disk_size" {
  description = "The volume size in GB used for the gateway(s)"
  type        = number
  default     = 60
}
variable "gateway_instance_name" {
  description = "The 'Name' tag applied to the gateway(s)"
  type        = string
  default     = "aap"
}
variable "gateway_ui_port" {
  description = "The gateway UI port"
  type        = string
  default     = "443"
}

# Database node variables
# TODO is this needed or can we hardcode it?  based on topologies
# this should only be needed for RPM growth and there would only
# be one
variable "database_instance_count" {
  description = "The number of database node instances to create"
  type        = number
  default     = 1
}
variable "database_instance_type" {
  description = "The instance type used for the database node"
  type        = string
  default     = ""
}
variable "database_image_id" {
  description = "The AMI ID used for the database node"
  type        = string
  default     = ""
}
variable "database_key_name" {
  description = "EC2 key pair associated with the database node"
  type        = string
  default     = ""
}
variable "database_disk_size" {
  description = "The volume size in GB used for the database node"
  type        = number
  default     = 60
}
variable "database_instance_name" {
  description = "The 'Name' tag applied to the database node"
  type        = string
  default     = "db"
}

# Execution node variables
variable "execution_instance_count" {
  description = "The number of execution node instances to create"
  type        = number
  default     = 1
}
variable "execution_instance_type" {
  description = "The instance type used for the execution node(s)"
  type        = string
  default     = ""
}
variable "execution_image_id" {
  description = "The AMI ID used for the execution node(s)"
  type        = string
  default     = ""
}
variable "execution_key_name" {
  description = "EC2 key pair associated with the execution node(s)"
  type        = string
  default     = ""
}
variable "execution_disk_size" {
  description = "The volume size in GB used for the execution node(s)"
  type        = number
  default     = 60
}
variable "execution_instance_name" {
  description = "The 'Name' tag applied to the execution node(s)"
  type        = string
  default     = "en"
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
variable "rds_db_family" {
  description = "Database family for RDS DB family parameter"
  type        = string
  default     = "postgres15"
}
variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.8"
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

# Automation dashboard node variables
variable "dashboard_instance_type" {
  description = "The instance type used for the dashboard node"
  type        = string
  default     = ""
}
variable "dashboard_image_id" {
  description = "The AMI ID used for the dashboard node(s)"
  type        = string
  default     = ""
}
variable "dashboard_key_name" {
  description = "EC2 key pair associated with the dashboard node(s)"
  type        = string
  default     = ""
}
variable "dashboard_disk_size" {
  description = "The volume size in GB used for the dashboard node(s)"
  type        = number
  default     = 60
}
variable "dashboard_instance_name" {
  description = "The 'Name' tag applied to the dashboard node(s)"
  type        = string
  default     = "en"
}
variable "dashboard_ui_port" {
  description = "The dashboard UI port"
  type        = string
  default     = "8447"
}
