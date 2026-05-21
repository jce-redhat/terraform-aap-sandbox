# Container enterprise topology - multi-node AAP deployment with RDS and NLB
# See: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/tested_deployment_models/index
#
# This will create:
# - 2 gateway nodes
# - 2 controller nodes
# - 2 hub nodes
# - 2 EDA nodes
# - 2 execution nodes
# - External RDS PostgreSQL instance
# - Network Load Balancer for SSL passthrough

# Mandatory variables
aws_dns_zone    = "sandbox123.example.com"
aws_key_content = "Add PUBLIC key string here"

# AAP Instances Configuration
aap_instances = {
  gateway    = { count = 2, node_type = "gateway" }
  controller = { count = 2, node_type = "controller" }
  hub        = { count = 2, node_type = "hub" }
  eda        = { count = 2, node_type = "eda" }
  execution  = { count = 2, node_type = "execution" }
}

# Optional: Deploy Network Load Balancer for gateway instances
deploy_with_nlb = true

# Optional: Deploy RDS PostgreSQL database
deploy_with_rds = true
