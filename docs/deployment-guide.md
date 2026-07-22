# Deployment Guide

This guide contains the detailed AWS and CI/CD setup that was moved out of the main README to keep the repository landing page recruiter-friendly.

## Prerequisites

- Terraform `1.10.0` or newer
- AWS CLI v2
- Docker
- An AWS CLI profile with appropriate permissions
- Access to the DNS provider for the API domain
- GitHub Actions enabled

Development configuration:

- Region: `eu-central-1`
- Environment: `dev`
- Project: `task-manager`
- API domain: `api.ridham-pansara-portfolio.online`

Do not use AWS root-account access keys.

```powershell
$env:AWS_PROFILE = "terraform-developer"
aws sts get-caller-identity
```

## Bootstrap Terraform Remote State

The bootstrap stack creates the encrypted, versioned S3 bucket used for Terraform state.

```powershell
cd terraformootstrap
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
cd ..\..
```

Do not destroy the bootstrap stack while an environment still uses its state bucket.

## Validate the Development Environment

```powershell
cd terraform\environments\dev
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

Provider requirements:

- Terraform `>= 1.10.0`
- AWS provider `~> 6.0`
- Random provider `~> 3.7`

## Bootstrap the Initial ECR Image

The initial ECS task definition expects `sha-initial`.

```powershell
terraform apply -target=aws_ecr_repository.app

$EcrUri = terraform output -raw ecr_repository_url
$Registry = ($EcrUri -split "/")[0]

aws ecr get-login-password `
  --region eu-central-1 |
docker login `
  --username AWS `
  --password-stdin $Registry

docker build -t "${EcrUri}:sha-initial" .
docker push "${EcrUri}:sha-initial"
```

Subsequent deployments use immutable `sha-<commit-sha>` tags.

## Deploy the Environment

```powershell
terraform plan
terraform apply
```

Useful outputs:

```powershell
terraform output
terraform output -raw ecr_repository_url
terraform output -raw alb_dns_name
terraform output -raw ecs_cluster_name
terraform output -raw ecs_service_name
terraform output -raw ecs_security_group_id
terraform output -raw github_deploy_role_arn
```

## GitHub Repository Variables

Open **Settings → Secrets and variables → Actions → Variables** and configure:

| Variable | Example |
|---|---|
| `AWS_REGION` | `eu-central-1` |
| `AWS_ROLE_ARN` | Terraform `github_deploy_role_arn` output |
| `ECR_REPOSITORY` | `task-manager-api` |
| `ECS_CLUSTER` | `task-manager-dev-cluster` |
| `ECS_SERVICE` | `task-manager-dev-service` |
| `ECS_TASK_DEFINITION` | `task-manager-dev` |
| `ECS_SUBNETS` | `subnet-abc,subnet-def` |
| `ECS_SECURITY_GROUP` | `sg-abc123` |
| `ALB_DNS` | `api.ridham-pansara-portfolio.online` |

No long-lived AWS access keys are stored in GitHub.

## Terraform and CI/CD Ownership Boundary

Terraform manages the VPC, subnets, security groups, ALB, ECS base service, IAM, RDS, Secrets Manager, CloudWatch, ECR, ACM, and the GitHub OIDC role.

GitHub Actions manages application image revisions after the base ECS service exists. The ECS service ignores later task-definition changes from Terraform:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

This prevents a later `terraform apply` from replacing a newer GitHub Actions deployment with an older Terraform-defined revision.

## Continuous Integration

`.github/workflows/ci.yml` runs on pushes and pull requests targeting `main`.

The workflow:

1. Checks out the repository.
2. Installs Python 3.12.
3. Installs development dependencies.
4. Runs Ruff lint checks.
5. Verifies Ruff formatting.
6. Runs Pytest.
7. Builds the Docker image.
8. Inspects the built image.

## Continuous Deployment

`.github/workflows/deploy.yml` runs on pushes to `main`.

```text
Checkout
  → Assume AWS role through OIDC
  → Authenticate to ECR
  → Build and push immutable image
  → Register task-definition revision
  → Run Alembic migration task
  → Verify migration exit code
  → Update ECS service
  → Wait for service stability
  → Run HTTPS /health smoke test
```

A concurrency group prevents overlapping development deployments.

## Database Migrations

Local migration:

```powershell
docker compose run --rm api python -m alembic upgrade head
```

AWS deployments run the same command in a one-off ECS task before updating the service. Deployment continues only when the migration container exits with code `0`.

Prefer backward-compatible schema changes: add compatible structures first, deploy code that supports both versions, migrate data, and remove deprecated structures later.

## HTTPS and Custom Domain

HTTPS uses:

- ACM certificate in `eu-central-1`
- DNS validation through the external DNS provider
- ALB HTTPS listener on port `443`
- HTTP-to-HTTPS redirect on port `80`
- CNAME from the API subdomain to the ALB DNS name

Keep the ACM DNS-validation record configured so AWS can renew the certificate automatically.
