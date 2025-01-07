

resource "aws_alb" "main" {
  name            = "${var.env}-${var.project_name}-alb"
  subnets         = var.public_subnet_ids
  security_groups = [var.lb_sg_id]
  tags = {
    Name        = "${var.env}-${var.project_name}-alb"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_alb_target_group" "app" {
  name        = "${var.env}-${var.project_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

 health_check {
  healthy_threshold   = "2"
  interval            = "10"
  protocol            = "HTTP"
  matcher             = "200"
  timeout             = "5"
  path                = "/login"
  unhealthy_threshold = "2"
  }
  tags = {
    Name        = "${var.env}-${var.project_name}-tg"
    Project     = var.project_name
    Environment = var.env
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "grafana" {
  name        = "${var.env}-${var.project_name}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 10
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-401"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-grafana-tg"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn =  aws_alb.main.id
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.grafana.arn
  }
}