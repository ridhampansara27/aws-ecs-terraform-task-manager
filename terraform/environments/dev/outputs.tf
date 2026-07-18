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