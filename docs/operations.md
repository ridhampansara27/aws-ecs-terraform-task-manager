# Operations Guide

## Monitoring and Logging

Application logs are written to:

```text
/ecs/task-manager-dev
```

Tail recent logs:

```powershell
aws logs tail "/ecs/task-manager-dev" `
  --region eu-central-1 `
  --since 15m `
  --follow
```

Configured CloudWatch alarms:

- ECS high CPU utilization
- ECS high memory utilization
- ALB HTTP 5xx responses
- Unhealthy ALB targets

Useful checks:

```powershell
aws ecs describe-services `
  --cluster task-manager-dev-cluster `
  --services task-manager-dev-service `
  --region eu-central-1
```

```powershell
aws elbv2 describe-target-health `
  --target-group-arn <target-group-arn> `
  --region eu-central-1
```

## Backup and Recovery

Development RDS settings prioritize low cost:

| Setting | Development value |
|---|---|
| Storage encryption | Enabled |
| Backup retention | 1 day |
| Multi-AZ | Disabled |
| Deletion protection | Disabled |
| Final snapshot on destroy | Disabled |
| Minor-version upgrades | Enabled |

> [!WARNING]
> `terraform destroy` can delete the development database without creating a final snapshot.

Create a manual snapshot before destructive operations:

```powershell
aws rds create-db-snapshot `
  --db-instance-identifier task-manager-dev-postgres `
  --db-snapshot-identifier task-manager-dev-manual-backup `
  --region eu-central-1
```

Check status:

```powershell
aws rds describe-db-snapshots `
  --db-snapshot-identifier task-manager-dev-manual-backup `
  --region eu-central-1
```

A production environment should enable deletion protection, final snapshots, longer retention, Multi-AZ, cross-region copies, and tested restoration procedures.

## ECS Application Rollback

List recent revisions:

```powershell
aws ecs list-task-definitions `
  --family-prefix task-manager-dev `
  --sort DESC `
  --region eu-central-1
```

Deploy a known working revision:

```powershell
aws ecs update-service `
  --cluster task-manager-dev-cluster `
  --service task-manager-dev-service `
  --task-definition task-manager-dev:<previous-revision> `
  --region eu-central-1

aws ecs wait services-stable `
  --cluster task-manager-dev-cluster `
  --services task-manager-dev-service `
  --region eu-central-1

curl.exe --fail https://api.ridham-pansara-portfolio.online/health
```

The ECS deployment circuit breaker is enabled and can roll back unhealthy revisions automatically.

## Database Rollback

Application rollback and database rollback are separate operations. Before an Alembic downgrade:

1. Confirm a downgrade revision exists.
2. Review whether it removes data.
3. Create an RDS snapshot.
4. Test in a non-production environment.
5. Confirm the previous application supports the downgraded schema.

```powershell
docker compose run --rm api python -m alembic downgrade -1
```

Forward-compatible migrations are preferred because destructive downgrades may cause permanent data loss.

## Cost Optimization

Implemented controls:

- No NAT Gateway
- One ECS Fargate application task
- Small Single-AZ RDS instance
- ECS scale-to-zero
- Temporarily stoppable RDS
- Limited CloudWatch retention
- ECR lifecycle cleanup
- No Multi-AZ, WAF, Container Insights, or production autoscaling

Resources that may still incur charges while compute is paused:

- Application Load Balancer
- RDS storage, backups, and snapshots
- S3 Terraform state
- CloudWatch logs
- ECR image storage
- Public IPv4 and DNS-related charges

## Start and Stop Scripts

Start the runtime:

```powershell
.\scripts\start-dev.ps1
```

The script starts RDS, waits for availability, and scales ECS to one task.

Stop the runtime:

```powershell
.\scripts\stop-dev.ps1
```

The script scales ECS to zero, waits for tasks to stop, and then stops RDS.

These scripts do not destroy infrastructure. The ALB, networking, RDS storage, ECR images, CloudWatch data, and Terraform state remain provisioned.
