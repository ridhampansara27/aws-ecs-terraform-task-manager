output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.app.arn
}




# Outputs for CloudWatch metrics
output "alb_arn_suffix" {
  description = "ARN suffix used by CloudWatch ALB metrics."
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix used by CloudWatch target group metrics."
  value       = aws_lb_target_group.app.arn_suffix
}