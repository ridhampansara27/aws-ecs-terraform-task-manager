# Security

## Implemented Controls

- HTTPS is enabled for the custom API domain.
- HTTP port `80` redirects to HTTPS port `443`.
- RDS is not publicly accessible and runs in private database subnets.
- RDS accepts PostgreSQL traffic only from the ECS security group.
- ECS accepts application traffic only from the ALB security group.
- Database credentials are generated automatically and stored in AWS Secrets Manager.
- The ECS execution role can read only the required database secret.
- GitHub Actions uses AWS OIDC instead of long-lived AWS access keys.
- The GitHub deployment role trust policy is restricted to the configured repository and branch, while deployment permissions are scoped to the required ECR, ECS, and ECS role-passing operations.
- ECR image tags are immutable.
- ECS uses separate task and execution roles.
- The ECS deployment circuit breaker is enabled.
- Terraform state is stored in a private, encrypted, versioned S3 bucket.
- The application container runs as a non-root user.
- CloudWatch log retention is configured.
- Sensitive values are removed or blurred from public screenshots.

Application responses include these security headers:

- `X-Content-Type-Options`
- `X-Frame-Options`
- `Referrer-Policy`
- `Permissions-Policy`

## Network Trust Boundaries

```text
Internet
  → ALB security group: ports 80 and 443
  → ECS security group: port 8000 from ALB only
  → RDS security group: port 5432 from ECS only
```

This uses security-group references rather than broad CIDR rules between application tiers.

## Development Security Trade-Off

To avoid the recurring cost of a NAT Gateway, ECS tasks run in public subnets with public IP assignment.

This does not make the application container directly reachable from the internet. Its security group permits inbound traffic only from the Application Load Balancer security group.

A more production-oriented design would place ECS tasks in private subnets and provide outbound access through either:

- A NAT Gateway, or
- VPC endpoints for ECR, CloudWatch, Secrets Manager, S3, and related AWS services.

## Current Security Gaps

The development environment does not yet include:

- API authentication or authorization
- API rate limiting
- AWS WAF
- Container image vulnerability scanning
- Terraform security scanning
- Dependency vulnerability scanning
- Dedicated production accounts or environments
- VPC Flow Logs and CloudTrail-focused monitoring

These items are documented transparently rather than represented as implemented controls. The current IAM configuration is deliberately scoped, but it is not described as mathematically minimal least privilege because some ECS API operations use broader resource scope.

## Public Documentation Safety

Never publish:

- AWS access keys
- Secret values or database passwords
- Private `.env` files
- Terraform state files
- Unblurred AWS account IDs
- Private endpoints, IP addresses, or sensitive resource identifiers
