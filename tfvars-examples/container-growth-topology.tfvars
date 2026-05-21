# Container growth topology - single-node containerized AAP deployment
# See: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/tested_deployment_models/index
#
# This will create a single instance for an all-in-one containerized deployment
# Uses the default aap_instances configuration (1x single-node, t3a.xlarge)

# Mandatory variables
aws_dns_zone    = "sandbox123.example.com"
aws_key_content = "Add PUBLIC key string here"
