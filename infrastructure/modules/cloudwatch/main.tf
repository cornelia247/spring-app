# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.env}-${var.project_name}-app"
  retention_in_days = 30

  tags = {
    Name        = "${var.env}-${var.project_name}-log-group"
    Project     = var.project_name
    Environment = var.env
  }
}
resource "aws_cloudwatch_log_group" "grafana_log_group" {
  name              = "/ecs/${var.env}-${var.project_name}-grafana"
  retention_in_days = 30

  tags = {
    Name        = "${var.env}-${var.project_name}-grafana-log-group"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "${var.env}-${var.project_name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
resource "aws_cloudwatch_log_stream" "grafana_log_stream" {
  name           = "${var.env}-${var.project_name}-grafana-log-stream"
  log_group_name = aws_cloudwatch_log_group.grafana_log_group.name
}
