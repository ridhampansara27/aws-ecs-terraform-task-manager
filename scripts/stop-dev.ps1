$ErrorActionPreference = "Stop"

$env:AWS_PROFILE = "terraform-developer"
$Region = "eu-central-1"
$Database = "task-manager-dev-postgres"
$Cluster = "task-manager-dev-cluster"
$Service = "task-manager-dev-service"

Write-Host "Scaling ECS service to zero..."

aws ecs update-service `
  --cluster $Cluster `
  --service $Service `
  --desired-count 0 `
  --region $Region | Out-Null

Write-Host "Waiting for ECS tasks to stop..."

do {
    Start-Sleep -Seconds 10

    $RunningCount = aws ecs describe-services `
      --cluster $Cluster `
      --services $Service `
      --region $Region `
      --query "services[0].runningCount" `
      --output text

    Write-Host "Running ECS tasks: $RunningCount"
} while ($RunningCount -ne "0")

Write-Host "Stopping RDS database..."

aws rds stop-db-instance `
  --db-instance-identifier $Database `
  --region $Region | Out-Null

Write-Host "Development environment stopped successfully."