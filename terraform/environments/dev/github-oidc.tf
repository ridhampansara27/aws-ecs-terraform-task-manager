# Create an IAM OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}


# Create an IAM role trust policy for GitHub Actions
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    # GitHub OIDC audience must be AWS STS
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    # Restrict access to this exact GitHub repository and main branch.
    # Uses GitHub's immutable OIDC subject format.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository_name}@${var.github_repository_id}:ref:refs/heads/main"
      ]
    }
  }
}


# Create GitHub deployment role for GitHub Actions to assume
resource "aws_iam_role" "github_deploy" {
  name = "${var.project_name}-${var.environment}-github-deploy-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}


# Create permissions policy for GitHub deployment
data "aws_iam_policy_document" "github_deploy" {

  # Allow GitHub Actions to authenticate with ECR
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  # Allow pushing and reading Docker images from this ECR repository
  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    resources = [
      aws_ecr_repository.app.arn
    ]
  }

  # Allow GitHub Actions to deploy new ECS task definition revisions
  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask",
      "ecs:UpdateService"
    ]

    resources = ["*"]
  }

  # Allow GitHub Actions to pass the existing ECS IAM roles
  # when registering a new ECS task definition
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      module.ecs.execution_role_arn,
      module.ecs.task_role_arn
    ]
  }
}


# Attach the deployment permissions policy to the GitHub deployment role
resource "aws_iam_role_policy" "github_deploy" {
  name = "${var.project_name}-${var.environment}-github-deploy-policy"

  role = aws_iam_role.github_deploy.id

  policy = data.aws_iam_policy_document.github_deploy.json
}