output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group used by the application."
  value       = aws_cloudwatch_log_group.app.name
}




# Outputs for IAM roles
output "execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "ECS application task role ARN."
  value       = aws_iam_role.task.arn
}

