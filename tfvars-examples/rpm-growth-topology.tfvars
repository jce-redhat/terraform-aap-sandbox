# RPM growth topology - traditional multi-node deployment with dedicated database
# See: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/tested_deployment_models/index
#
# This will create:
# - 1 gateway node
# - 1 controller node
# - 1 hub node
# - 1 EDA node
# - 1 execution node
# - 1 database node

# Mandatory variables
aws_dns_zone    = "sandbox123.example.com"
aws_key_content = "Add PUBLIC key string here"

# AAP Instances Configuration
aap_instances = {
  gateway    = { count = 1, node_type = "gateway" }
  controller = { count = 1, node_type = "controller" }
  hub        = { count = 1, node_type = "hub" }
  eda        = { count = 1, node_type = "eda" }
  execution  = { count = 1, node_type = "execution" }
  database   = { count = 1, node_type = "database" }
}
