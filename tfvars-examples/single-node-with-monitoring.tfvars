# Single-node AAP with CloudTrail monitoring
# Deploys containerized AAP instance and monitors EC2 RunInstances events in the same region

# Mandatory variables
aws_dns_zone    = "sandbox123.example.com"
aws_key_content = "Add PUBLIC key string here"

# Enable CloudTrail monitoring
enable_cloudtrail_monitoring = true

# Default single-node AAP instance (uses defaults from vars.tf)
# Uncomment to customize:
# aap_instances = {
#   aap = {
#     count         = 1
#     instance_type = "t3a.xlarge"
#     node_type     = "single-node"
#   }
# }

# Optional: Filter events to only instances created with specific tags
# monitored_instance_tags = {
#   Environment = "production"
#   ManagedBy   = "terraform"
# }
