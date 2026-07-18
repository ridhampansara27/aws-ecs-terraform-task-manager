# Outputs for the ECR repository
output "ecr_repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.app.name
}


output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = aws_ecr_repository.app.repository_url
}


# Outputs for the networking module
output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of private database subnets."
  value       = module.networking.private_db_subnet_ids
}




# Outputs for the security module
output "alb_security_group_id" {
  description = "Security group ID for ALB."
  value       = module.security.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS."
  value       = module.security.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS."
  value       = module.security.rds_security_group_id
}




# Outputs for the database module
output "database_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.database.database_endpoint
}

output "database_secret_arn" {
  description = "ARN of the database secret."
  value       = module.database.database_secret_arn
}




# Outputs for the load balancer module
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.load_balancer.alb_dns_name
}




# Outputs for the ECS module
output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "cloudwatch_log_group_name" {
  description = "Application CloudWatch log group."
  value       = module.ecs.cloudwatch_log_group_name
}