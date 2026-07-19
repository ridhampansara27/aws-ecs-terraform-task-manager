resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name = "${var.project_name}-${var.environment}-ecs-high-cpu"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"

  period    = 300
  statistic = "Average"

  threshold = 80

  alarm_description = "ECS service average CPU utilization is above 80 percent."

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  treat_missing_data = "notBreaching"
}




# Create a CloudWatch alarm for high ECS memory utilization
resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  alarm_name = "${var.project_name}-${var.environment}-ecs-high-memory"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "MemoryUtilization"
  namespace   = "AWS/ECS"

  period    = 300
  statistic = "Average"

  threshold = 80

  alarm_description = "ECS service average memory utilization is above 80 percent."

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  treat_missing_data = "notBreaching"
}




# Create a CloudWatch alarm for ALB 5xx errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name = "${var.project_name}-${var.environment}-alb-5xx"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "HTTPCode_ELB_5XX_Count"
  namespace   = "AWS/ApplicationELB"

  period    = 300
  statistic = "Sum"

  threshold = 5

  alarm_description = "ALB returned more than five HTTP 5xx responses within five minutes."

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  treat_missing_data = "notBreaching"
}




# Create a CloudWatch alarm for unhealthy targets in the ALB target group
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name = "${var.project_name}-${var.environment}-unhealthy-targets"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "UnHealthyHostCount"
  namespace   = "AWS/ApplicationELB"

  period    = 60
  statistic = "Maximum"

  threshold = 0

  alarm_description = "One or more ECS targets are unhealthy."

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "notBreaching"
}