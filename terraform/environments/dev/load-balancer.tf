module "load_balancer" {
  source = "../../modules/load-balancer"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.networking.vpc_id

  public_subnet_ids = module.networking.public_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id

  app_port = 8000

  certificate_arn = aws_acm_certificate_validation.api.certificate_arn
}