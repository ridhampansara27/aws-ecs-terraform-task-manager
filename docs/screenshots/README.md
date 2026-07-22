# Project Screenshot Gallery

These screenshots provide visual evidence of the deployed application, CI/CD workflows, AWS runtime, security configuration, monitoring, and Terraform-managed infrastructure.

Sensitive values such as account IDs, ARNs, database endpoints, private IP addresses, subnet IDs, secret identifiers, and other account-specific data must be blurred before publication.

## Application and API

| Swagger API Documentation | HTTPS Health Check |
|---|---|
| [![Swagger API documentation](01-swagger-docs.png)](01-swagger-docs.png) | [![HTTPS health check](02-https-health.png)](02-https-health.png) |

| Task CRUD Response |
|---|
| [![Task CRUD response](03-task-crud-response.png)](03-task-crud-response.png) |

## Continuous Integration and Deployment

| GitHub CI Success | GitHub Deployment Success |
|---|---|
| [![GitHub CI success](04-github-ci-success.png)](04-github-ci-success.png) | [![GitHub deployment success](05-github-deploy-success.png)](05-github-deploy-success.png) |

## AWS Runtime and Security

| ECS Service Running | ALB Target Healthy |
|---|---|
| [![ECS service running](06-ecs-service-running.png)](06-ecs-service-running.png) | [![ALB target healthy](07-alb-target-healthy.png)](07-alb-target-healthy.png) |

| RDS Private Configuration | Secrets Manager Configuration |
|---|---|
| [![RDS private configuration](08-rds-private-config.png)](08-rds-private-config.png) | [![Secrets Manager database configuration](09-secrets-manager-database.png)](09-secrets-manager-database.png) |

## Monitoring and Infrastructure

| CloudWatch Logs | CloudWatch Alarms |
|---|---|
| [![CloudWatch logs](10-cloudwatch-logs.png)](10-cloudwatch-logs.png) | [![CloudWatch alarms](11-cloudwatch-alarms.png)](11-cloudwatch-alarms.png) |

| Terraform Outputs | ACM Certificate Issued |
|---|---|
| [![Terraform outputs](12-terraform-outputs.png)](12-terraform-outputs.png) | [![ACM certificate issued](13-acm-certificate-issued.png)](13-acm-certificate-issued.png) |

Select any image to open it at full size.

## Publication Safety

Never publish:

- AWS access keys
- Secret values
- Database passwords
- Private `.env` files
- Terraform state files
- Unblurred AWS account IDs
- Sensitive private endpoints or resource identifiers
