$ErrorActionPreference = "Stop"

$env:AWS_PROFILE = "terraform-developer"
$Region = "eu-central-1"
$Database = "task-manager-dev-postgres"
$Cluster = "task-manager-dev-cluster"
$Service = "task-manager-dev-service"

Write-Host "Starting RDS database..."

aws rds start-db-instance `
  --db-instance-identifier $Database `
  --region $Region | Out-Null

Write-Host "Waiting for RDS to become available..."

aws rds wait db-instance-available `
  --db-instance-identifier $Database `
  --region $Region

Write-Host "Starting ECS service..."

aws ecs update-service `
  --cluster $Cluster `
  --service $Service `
  --desired-count 1 `
  --region $Region | Out-Null

Write-Host "Development environment started successfully."