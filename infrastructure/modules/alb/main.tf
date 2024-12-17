

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
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-401"
    timeout             = "3"
    path                = "/"
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