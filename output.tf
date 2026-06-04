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

# CloudTrail monitoring outputs
output "instance_monitoring_queue_url" {
  description = "SQS queue URL for EC2 instance events (for AAP EDA rulebook configuration)"
  value       = var.enable_cloudtrail_monitoring ? aws_sqs_queue.instance_events[0].url : null
}

output "instance_monitoring_queue_arn" {
  description = "SQS queue ARN for EC2 instance events"
  value       = var.enable_cloudtrail_monitoring ? aws_sqs_queue.instance_events[0].arn : null
}

output "cloudtrail_trail_name" {
  description = "Name of the CloudTrail trail for instance monitoring"
  value       = var.enable_cloudtrail_monitoring ? aws_cloudtrail.monitoring[0].name : null
}

output "cloudtrail_trail_arn" {
  description = "ARN of the CloudTrail trail for instance monitoring"
  value       = var.enable_cloudtrail_monitoring ? aws_cloudtrail.monitoring[0].arn : null
}
