provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-ecs-terraform-task-manager"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Ridham"
    }
  }
}