variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL containing the application image."
  type        = string
}

variable "image_tag" {
  description = "Docker image tag deployed to ECS."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by ECS tasks."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group attached to ECS tasks."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN."
  type        = string
}

variable "database_secret_arn" {
  description = "ARN of the Secrets Manager database secret."
  type        = string
}

variable "app_port" {
  description = "Application container port."
  type        = number
  default     = 8000
}