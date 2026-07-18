# Create a random password for the database
resource "random_password" "database" {
  length  = 24
  special = true

  override_special = "!#$%&*()-_=+[]{}<>:?"
}




# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-${var.environment}-db-subnet-group"

  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}




# Create a Secrets Manager secret for the database credentials
resource "aws_secretsmanager_secret" "database" {
  name = "${var.project_name}/${var.environment}/database"

  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-${var.environment}-database-secret"
  }
}




# Create a Secrets Manager secret version with the database credentials
resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id

  secret_string = jsonencode({
    username = var.database_username
    password = random_password.database.result
    database = var.database_name
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
  })
}




# Create a PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine = "postgres"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.database_username
  password = random_password.database.result

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    var.rds_security_group_id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1

  deletion_protection = false
  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  apply_immediately = true

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}