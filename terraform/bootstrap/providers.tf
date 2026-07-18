provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-ecs-terraform-task-manager"
      Environment = "bootstrap"
      ManagedBy   = "Terraform"
      Owner       = "Ridham"
    }
  }
}