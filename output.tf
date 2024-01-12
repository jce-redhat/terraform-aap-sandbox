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
output "bastion_public_fqdn" {
  description = "Public FQDN of the AAP bastion"
  value       = length(aws_instance.bastion) > 0 ? aws_route53_record.bastion[0].name : null
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = length(aws_db_instance.aap) > 0 ? aws_db_instance.aap[0].address : null
  #sensitive   = true
}
