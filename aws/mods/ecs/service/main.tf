# security group

data "aws_vpc" "ingress" {
  id = var.vpc_id
}

resource "aws_security_group" "service_sg" {

  name        = "${var.prefix}-service-sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.port
    to_port     = var.port
    cidr_blocks = [data.aws_vpc.ingress.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prefix}-service-sg"
  }

}

resource "aws_lb_target_group" "service_target_group" {

  name     = "${var.prefix}-service-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  health_check {
    path                = "/status"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.prefix}-service-tg"
  }
}

# listener rule to forward to target group
resource "aws_alb_listener_rule" "service_listener_rule" {
  
  listener_arn = var.listener_arn
  priority     = var.listener_priority

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }

  condition {
    http_header {
      http_header_name = "x-service-name"
      values           = ["service"]
    }
  }

}

resource "aws_ecs_service" "service" {

  name                              = var.name
  cluster                           = var.cluster
  task_definition                   = var.task_definition
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = 30
  launch_type                       = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.service_sg.id]
    subnets         = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_target_group.arn
    container_name   = "${var.prefix}-${var.name}"
    container_port   = var.port
  }

  # avoid changes
  lifecycle {
    ignore_changes = [desired_count, task_definition] # , load_balancer]
  }

}