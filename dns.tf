data "aws_route53_zone" "aap_zone" {
  name = var.aws_dns_zone
}

# Unified DNS records for all AAP instances managed by the module
resource "aws_route53_record" "aap" {
  for_each = module.ec2_instances.eips

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name    = "${module.ec2_instances.instance_names[each.key]}.${var.aws_dns_zone}"
  type    = "A"
  ttl     = "300"
  records = [each.value.public_ip]
}

# Legacy resources (to be refactored in future phases)
resource "aws_route53_record" "gateway_lb" {
  count = var.deploy_with_nlb ? 1 : 0

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name    = "${var.gateway_lb_name}.${var.aws_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = [
    aws_lb.aap_nlb[0].dns_name
  ]
}
