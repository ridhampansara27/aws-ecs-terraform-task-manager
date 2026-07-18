resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}




resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Remove old untagged images"

        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }

        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2

        description = "Keep only the latest 15 tagged images"

        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["sha-"]
          countType     = "imageCountMoreThan"
          countNumber   = 15
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}