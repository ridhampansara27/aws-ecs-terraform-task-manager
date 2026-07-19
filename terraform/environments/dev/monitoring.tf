module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name

  alb_arn_suffix          = module.load_balancer.alb_arn_suffix
  target_group_arn_suffix = module.load_balancer.target_group_arn_suffix
}