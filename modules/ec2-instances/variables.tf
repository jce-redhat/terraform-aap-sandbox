variable "ec2_instances" {
  description = "Map of instances to create (can include AAP nodes and arbitrary instances)"
  type = map(object({
    count                = number
    instance_type        = string
    disk_size            = number
    key_name             = string
    image_id             = string
    node_os              = string
    arch                 = string
    name_prefix          = string
    security_groups      = list(string)
    node_type            = string
    create_eip           = bool
    iam_instance_profile = string
  }))
}

variable "instance_type" {
  description = "Instance type to use when not specified per instance"
  type        = string
}

variable "key_name" {
  description = "SSH key name to use when not specified per instance"
  type        = string
}

variable "ami_ids" {
  description = "Map of OS and architecture combinations to AMI IDs (e.g., rhel9-x86_64, rhel9-arm64)"
  type        = map(string)
}

variable "arch" {
  description = "CPU architecture to use when not specified per instance (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "disk_size" {
  description = "Root disk size in GB when not specified per instance"
  type        = number
  default     = 60
}

variable "subnet_id" {
  description = "Subnet ID for all instances"
  type        = string
}

variable "security_group_ids" {
  description = "Map of security group names to IDs"
  type        = map(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
