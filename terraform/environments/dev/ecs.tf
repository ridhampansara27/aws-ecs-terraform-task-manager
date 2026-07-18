module "ecs" {
  source = "../../modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  ecr_repository_url = aws_ecr_repository.app.repository_url

  image_tag = "sha-initial"

  public_subnet_ids = module.networking.public_subnet_ids

  ecs_security_group_id = module.security.ecs_security_group_id

  target_group_arn = module.load_balancer.target_group_arn

  database_secret_arn = module.database.database_secret_arn

  app_port = 8000
}