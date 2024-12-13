resource "aws_cloudwatch_metric_alarm" "metric_alert" {
  alarm_name          = "${var.prefix}-${var.metric_name}-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.metric_name
  namespace           = "AWS/ECR" # Adjust namespace based on resource. ECR uses "AWS/ECR", ALB uses "AWS/ELB".
  period              = 300
  statistic           = "Sum"
  threshold           = var.metric_threshold

  # You must set the correct namespace and dimensions for the metric.
  # For example, ECR might require no dimension or a repositoryName dimension.
  # ALB metrics need LoadBalancer dimension.
  # This is just a placeholder. You must look up the correct metric namespace and dimensions.
  
  # dimensions = {
  #   "RepositoryName" = "..."
  # }

  alarm_description = "Alarm when ${var.metric_name} exceeds ${var.metric_threshold}"
}