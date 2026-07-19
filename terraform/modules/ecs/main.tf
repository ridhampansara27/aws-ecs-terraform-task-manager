# Create an ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}




# Create a CloudWatch log group for the ECS tasks
resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${var.project_name}-${var.environment}"

  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-logs"
  }
}




# Create an IAM role for the ECS task execution
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

# Create an IAM role for the ECS task execution
resource "aws_iam_role" "execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}




# Create an IAM policy for the ECS task execution role to access Secrets Manager
data "aws_iam_policy_document" "execution_secrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.database_secret_arn
    ]
  }
}

# Attach the policy to the ECS task execution role
resource "aws_iam_role_policy" "execution_secrets" {
  name = "${var.project_name}-${var.environment}-ecs-secrets-policy"

  role = aws_iam_role.execution.id

  policy = data.aws_iam_policy_document.execution_secrets.json
}




# Create an IAM role for the ECS task to access Secrets Manager
resource "aws_iam_role" "task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}




# Create an IAM policy for the ECS task role to access Secrets Manager
resource "aws_ecs_task_definition" "app" {
  family = "${var.project_name}-${var.environment}"

  requires_compatibilities = [
    "FARGATE"
  ]

  network_mode = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name = "api"

      image = "${var.ecr_repository_url}:${var.image_tag}"

      essential = true

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_NAME"
          value = "Cloud Native Task Manager"
        },
        {
          name  = "APP_ENV"
          value = var.environment
        },
        {
          name  = "APP_PORT"
          value = tostring(var.app_port)
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${var.database_secret_arn}:database_url::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-${var.environment}-task-definition"
  }
}




# Create an ECS Fargate service to run the application container
resource "aws_ecs_service" "app" {
  name = "${var.project_name}-${var.environment}-service"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 1

  launch_type = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
        task_definition
    ]
  }

  network_configuration {
    subnets = var.public_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn

    container_name = "api"
    container_port = var.app_port
  }

  health_check_grace_period_seconds = 60

  depends_on = [
    aws_iam_role_policy_attachment.execution,
    aws_iam_role_policy.execution_secrets
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-service"
  }



}