# create a network load balancer for SSL pass-through to the gateway servers
resource "aws_lb" "aap_nlb" {
  count = var.deploy_with_nlb ? 1 : 0

  name               = var.gateway_lb_name
  load_balancer_type = "network"
  internal           = "false"
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "aap_nlb" {
  count = var.deploy_with_nlb ? 1 : 0

  load_balancer_arn = aws_lb.aap_nlb[0].arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway[0].arn
  }
}

resource "aws_lb_target_group" "gateway" {
  count = var.deploy_with_nlb ? 1 : 0

  name        = "gateway-target-group-${local.deployment_id}"
  vpc_id      = module.vpc.vpc_id
  port        = var.gateway_ui_port
  protocol    = "TCP"
  target_type = "instance"

  stickiness {
    type    = "source_ip"
    enabled = true
  }

  health_check {
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  deregistration_delay = 60

  depends_on = [
    aws_lb.aap_nlb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "gateway" {
  count = var.deploy_with_nlb ? length(aws_instance.gateway) : 0

  target_group_arn = aws_lb_target_group.gateway[0].arn
  target_id        = aws_instance.gateway[count.index].id
  port             = var.gateway_ui_port
}
