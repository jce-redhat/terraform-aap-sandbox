data "aws_route53_zone" "aap_zone" {
  name = var.aws_dns_zone
}

resource "aws_route53_record" "single_node" {
  count = var.deploy_single_node ? var.single_node_instance_count : 0

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.single_node_instance_count == 1 ? (
    "${var.single_node_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.single_node_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.single_node[count.index].public_ip
  ]
}

resource "aws_route53_record" "controller" {
  count = var.deploy_single_node ? 0 : var.controller_instance_count

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.controller_instance_count == 1 ? (
    "${var.controller_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.controller_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.controller[count.index].public_ip
  ]
}

resource "aws_route53_record" "hub" {
  count = var.deploy_single_node ? 0 : var.hub_instance_count

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.hub_instance_count == 1 ? (
    "${var.hub_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.hub_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.hub[count.index].public_ip
  ]
}

resource "aws_route53_record" "eda" {
  count = var.deploy_single_node ? 0 : var.eda_instance_count

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.eda_instance_count == 1 ? (
    "${var.eda_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.eda_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.eda[count.index].public_ip
  ]
}

resource "aws_route53_record" "gateway" {
  count = var.deploy_single_node ? 0 : var.gateway_instance_count

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.gateway_instance_count == 1 ? (
    "${var.gateway_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.gateway_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.gateway[count.index].public_ip
  ]
}

resource "aws_route53_record" "database" {
  count = var.deploy_single_node ? 0 : var.database_instance_count

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.database_instance_count == 1 ? (
    "${var.database_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.database_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.database[count.index].public_ip
  ]
}

resource "aws_route53_record" "execution" {
  count = var.deploy_single_node ? 0 : var.execution_instance_count

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name = (var.execution_instance_count == 1 ? (
    "${var.execution_instance_name}.${var.aws_dns_zone}"
    ) : (
    "${var.execution_instance_name}${count.index}.${var.aws_dns_zone}"
  ))
  type = "A"
  ttl  = "300"
  records = [
    aws_eip.execution[count.index].public_ip
  ]
}

resource "aws_route53_record" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  zone_id = data.aws_route53_zone.aap_zone.zone_id
  name    = "bastion.${var.aws_dns_zone}"
  type    = "A"
  ttl     = "300"
  records = [
    aws_eip.bastion[count.index].public_ip
  ]
}
