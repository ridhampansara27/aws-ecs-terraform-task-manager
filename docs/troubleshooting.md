# Troubleshooting

## Docker Cannot Connect to the Daemon

Start Docker Desktop and verify:

```powershell
docker info
```

## Docker Compose Database Is Not Healthy

```powershell
docker compose ps
docker compose logs db
```

Confirm that `.env` contains matching PostgreSQL database, username, password, and `DATABASE_URL` values.

## PowerShell Cannot Find Pytest or Ruff

```powershell
.venv\Scripts\Activate.ps1
python -m pytest
python -m ruff check .
```

Running tools through Python avoids PATH resolution problems.

## ECR Login Fails in PowerShell

Confirm identity and region:

```powershell
aws sts get-caller-identity
aws configure get region
```

When PowerShell piping causes authentication problems, use Command Prompt:

```cmd
aws ecr get-login-password --profile terraform-developer --region eu-central-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-central-1.amazonaws.com
```

## Alembic Reports Invalid Interpolation Syntax

Database URLs can contain URL-encoded `%` characters. Escape `%` before passing the database URL to Alembic configuration.

## GitHub Actions Cannot Assume the AWS Role

Check that:

- `AWS_ROLE_ARN` matches the Terraform output.
- The workflow includes `id-token: write`.
- The AWS OIDC provider exists.
- The role trust policy matches the repository and branch.
- The configured immutable GitHub owner and repository IDs are correct.
- The workflow is running from the expected repository.

## ECS Migration Task Fails

Inspect CloudWatch logs:

```powershell
aws logs tail "/ecs/task-manager-dev" `
  --region eu-central-1 `
  --since 15m
```

Inspect the stopped task:

```powershell
aws ecs describe-tasks `
  --cluster task-manager-dev-cluster `
  --tasks <migration-task-arn> `
  --region eu-central-1
```

Confirm that:

- The migration task uses the newly registered task definition.
- The image contains the Alembic configuration and migrations.
- The task can read the database secret.
- The ECS security group can connect to RDS.
- RDS is running and available.
- The migration container exits with code `0`.

## ECS Cannot Pull the Initial Image

The ECR repository must contain the bootstrap tag:

```text
sha-initial
```

List images:

```powershell
aws ecr list-images `
  --repository-name task-manager-api `
  --region eu-central-1
```

## Terraform Attempts to Revert the ECS Task Definition

GitHub Actions manages application task-definition revisions after the base service exists. The ECS service uses:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

This prevents Terraform from replacing a newer CI/CD deployment with an older Terraform-defined revision.

## Live API Is Unavailable

The cost-controlled environment may be paused.

```powershell
.\scripts\start-dev.ps1
```

Verify RDS:

```powershell
aws rds describe-db-instances `
  --db-instance-identifier task-manager-dev-postgres `
  --region eu-central-1
```

Verify ECS:

```powershell
aws ecs describe-services `
  --cluster task-manager-dev-cluster `
  --services task-manager-dev-service `
  --region eu-central-1
```

Then test:

```powershell
curl.exe --fail https://api.ridham-pansara-portfolio.online/health
```

## Deployment Fails After a Destructive Database Migration

The deployment workflow runs Alembic before updating the ECS service. During the rolling deployment, the previous application revision may still be serving traffic.

Use backward-compatible migrations:

1. Add new columns or tables without removing existing structures.
2. Deploy application code that supports both the old and new schema.
3. Migrate or backfill data.
4. Remove deprecated structures in a later deployment.

Avoid renaming or dropping columns in the same release that first stops using them.
