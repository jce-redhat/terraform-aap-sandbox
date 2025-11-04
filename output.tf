output "deployment_id" {
  description = "Unique ID associated with this terraform deployment"
  value       = local.deployment_id
}
output "single_node_public_fqdn" {
  description = "Public FQDN of the AAP AIO instance"
  value       = length(aws_instance.single_node) > 0 ? aws_route53_record.single_node.*.name : null
}
output "controller_public_fqdn" {
  description = "Public FQDN of the AAP controller instance(s)"
  value       = length(aws_instance.controller) > 0 ? aws_route53_record.controller.*.name : null
}
output "hub_public_fqdn" {
  description = "Public FQDN of the AAP hub instance(s)"
  value       = length(aws_instance.hub) > 0 ? aws_route53_record.hub.*.name : null
}
output "eda_public_fqdn" {
  description = "Public FQDN of the AAP EDA instance(s)"
  value       = length(aws_instance.eda) > 0 ? aws_route53_record.eda.*.name : null
}
output "gateway_public_fqdn" {
  description = "Public FQDN of the AAP gateway instance(s)"
  value       = length(aws_instance.gateway) > 0 ? aws_route53_record.gateway.*.name : null
}
output "gateway_lb_public_fqdn" {
  description = "Public FQDN of the AAP gateway load balancer"
  value       = length(aws_lb.aap_nlb) > 0 ? aws_route53_record.gateway_lb.*.name : null
}
output "database_public_fqdn" {
  description = "Public FQDN of the AAP database instance"
  value       = length(aws_instance.database) > 0 ? aws_route53_record.database.*.name : null
}
output "execution_public_fqdn" {
  description = "Public FQDN of the AAP execution node instance(s)"
  value       = length(aws_instance.execution) > 0 ? aws_route53_record.execution.*.name : null
}
output "bastion_public_fqdn" {
  description = "Public FQDN of the AAP bastion"
  value       = length(aws_instance.bastion) > 0 ? aws_route53_record.bastion[0].name : null
}
output "dashboard_public_fqdn" {
  description = "Public FQDN of the AAP Automation Dashboard"
  value       = length(aws_instance.dashboard) > 0 ? aws_route53_record.dashboard[0].name : null
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = length(aws_db_instance.aap) > 0 ? aws_db_instance.aap[0].address : null
  #sensitive   = true
}
