variable "project_name" {
  description = "Project name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private subnet IDs used by the RDS subnet group."
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID attached to RDS."
  type        = string
}

variable "database_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "taskmanager"
}

variable "database_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "taskuser"
}