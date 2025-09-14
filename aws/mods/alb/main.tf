resource "aws_security_group" "service_sg" {

  count       = var.create_alb == true ? 1 : 0

  name        = "${var.prefix}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prefix}-alb-sg"
  }

}

resource "aws_alb" "alb" {
  count              = var.create_alb == true ? 1 : 0
  name               = "${var.prefix}-alb"
  subnets            = var.subnets
  security_groups    = [aws_security_group.service_sg[0].id]
  load_balancer_type = "application"
  internal           = false
  enable_http2       = true
  idle_timeout       = 30
}

resource "aws_alb_listener" "http_listener" {
  count             = var.create_alb == true ? 1 : 0
  load_balancer_arn = aws_alb.alb[0].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  lifecycle {
    ignore_changes = [default_action]
  }

}
