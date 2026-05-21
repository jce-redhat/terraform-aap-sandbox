output "deployment_id" {
  description = "Unique ID associated with this terraform deployment"
  value       = local.deployment_id
}

output "instances" {
  description = "All AAP instances with their details (ID, IPs, name, node type)"
  value       = module.ec2_instances.instances
}

output "instance_fqdns" {
  description = "Fully qualified domain names for all AAP instances"
  value = {
    for k, v in aws_route53_record.aap : k => v.name
  }
}

# Legacy outputs (to be refactored in future phases)
output "gateway_lb_public_fqdn" {
  description = "Public FQDN of the AAP gateway load balancer"
  value       = length(aws_lb.aap_nlb) > 0 ? aws_route53_record.gateway_lb[0].name : null
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = length(aws_db_instance.aap) > 0 ? aws_db_instance.aap[0].address : null
}
