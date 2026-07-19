variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service."
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group."
  type        = string
}