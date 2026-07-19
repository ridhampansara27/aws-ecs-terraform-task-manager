# Create an IAM OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}




# Create an IAM role for GitHub Actions to assume
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

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_repository}:*"
      ]
    }
  }
}




# Create GitHub deployment role for GitHub Actions to assume
resource "aws_iam_role" "github_deploy" {
  name = "${var.project_name}-${var.environment}-github-deploy-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}




# Attach the GitHub deployment policy to the GitHub deployment role
data "aws_iam_policy_document" "github_deploy" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

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

  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]

    resources = ["*"]
  }

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


# Create an IAM role policy for the GitHub deployment role
resource "aws_iam_role_policy" "github_deploy" {
  name = "${var.project_name}-${var.environment}-github-deploy-policy"

  role = aws_iam_role.github_deploy.id

  policy = data.aws_iam_policy_document.github_deploy.json
}