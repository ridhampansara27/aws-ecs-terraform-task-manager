variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "app_port" {
  description = "Port exposed by the FastAPI application."
  type        = number
  default     = 8000
}

variable "db_port" {
  description = "PostgreSQL database port."
  type        = number
  default     = 5432
}