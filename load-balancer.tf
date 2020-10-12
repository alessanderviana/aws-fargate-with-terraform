resource "aws_lb" "applb" {
  name               = "${var.name}-applb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.applb.name,] # var.alb_security_groups
  subnets            = [for s in data.aws_subnet.subnets : s.id] # var.subnets.*.id

  enable_deletion_protection = false
}

resource "aws_alb_target_group" "tgroup" {
  name        = "${var.name}-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id # var.vpc_id
  target_type = "ip"

  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   unhealthy_threshold = "2"
   # path                = var.health_check_path
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.applb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tgroup.id
    type             = "forward"
  }

  # default_action {
  #  type = "redirect"
  #
  #  redirect {
  #    port        = 443
  #    protocol    = "HTTPS"
  #    status_code = "HTTP_301"
  #  }
  # }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.applb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = var.alb_tls_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.tgroup.id
    type             = "forward"
  }
}
