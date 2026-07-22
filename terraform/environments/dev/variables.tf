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

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the development environment."
  type        = list(string)

  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks used by public subnets."
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks used by private database subnets."
  type        = list(string)

  default = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
}


variable "github_repository" {
  description = "GitHub repository allowed to deploy to AWS."
  type        = string
  default     = "ridhampansara27/aws-ecs-terraform-task-manager"
}

variable "github_owner" {
  description = "GitHub repository owner."
  type        = string
  default     = "ridhampansara27"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID used in the OIDC subject."
  type        = string
  default     = "70193760"
}

variable "github_repository_name" {
  description = "GitHub repository name."
  type        = string
  default     = "aws-ecs-terraform-task-manager"
}

variable "github_repository_id" {
  description = "Immutable GitHub repository ID used in the OIDC subject."
  type        = string
  default     = "1304106902"
}


variable "api_domain_name" {
  description = "Public domain name used for the Task Manager API."
  type        = string
  default     = "api.ridham-pansara-portfolio.online"
}