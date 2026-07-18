module "database" {
  source = "../../modules/database"

  project_name = var.project_name
  environment  = var.environment

  private_db_subnet_ids = module.networking.private_db_subnet_ids

  rds_security_group_id = module.security.rds_security_group_id

  database_name     = "taskmanager"
  database_username = "taskuser"
}