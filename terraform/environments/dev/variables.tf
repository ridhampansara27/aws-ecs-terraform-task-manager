variable "aws_region" {
  description = "AWS region used for project resources."
  type        = string
  default     = "eu-central-1"
}


variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}


variable "project_name" {
  description = "Project name used for AWS resource naming."
  type        = string
  default     = "task-manager"
}