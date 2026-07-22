# Project Roadmap

This roadmap records planned improvements separately from features that are already implemented. Items should only be presented as active capabilities after they are completed and validated.

## Priority Improvements

1. Add Terraform validation and security scanning to CI.
2. Add API authentication, authorization, rate limiting, and pagination.
3. Publish test coverage and enforce a minimum threshold.
4. Add private ECS subnets, autoscaling, and a separate production environment.
5. Add structured logging, request correlation IDs, metrics, and notifications.

## Security and Compliance

- Add AWS WAF in front of the ALB.
- Add API authentication and authorization.
- Add rate limiting.
- Add Checkov or Trivy Terraform scanning.
- Add Trivy container image scanning.
- Add dependency vulnerability scanning.
- Add Dependabot for Python, Docker, Terraform, and GitHub Actions.
- Add secret scanning and CodeQL.
- Pin GitHub Actions to immutable commit SHAs.

## Reliability

- Add Multi-AZ RDS for production.
- Enable RDS deletion protection and final snapshots.
- Increase automated backup retention.
- Add RDS CPU, storage, connection, and memory alarms.
- Add SNS notifications for alarms.
- Add ECS autoscaling.
- Move ECS to private subnets with VPC endpoints or a NAT Gateway.
- Add automated rollback verification.
- Add a separate production environment.

## CI/CD

- Add `terraform fmt -check -recursive`.
- Add `terraform init -backend=false` and `terraform validate`.
- Add Terraform plan output to pull requests.
- Add Docker image vulnerability scanning.
- Add Python dependency scanning.
- Add test coverage reporting and a minimum threshold.
- Add manual approval for production deployments.
- Add deployment environments and protected branches.

## Application

- Replace free-form status and priority strings with enums.
- Add task-list pagination, filtering, and sorting.
- Add structured JSON logging.
- Add request correlation IDs.
- Add API metrics.
- Add a frontend task-management interface.
- Export the OpenAPI specification into the documentation directory.
- Consider changing partial updates from `PUT` to `PATCH` for clearer REST semantics.

## Infrastructure

- Add Route 53 hosted-zone automation.
- Add separate `dev`, `staging`, and `prod` environments.
- Add VPC Flow Logs.
- Add CloudTrail-focused monitoring.
- Add Terraform drift detection.
- Add AWS budget and cost-anomaly alerts.
