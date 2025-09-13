# log group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/${var.prefix}/${var.name}"
  retention_in_days = 14
}

# current account
data "aws_caller_identity" "current" {}


# roles
resource "aws_iam_role" "execution_role" {
  name               = "${var.name}-execution-role"
  assume_role_policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          Service: "ecs-tasks.amazonaws.com"
        },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })

  inline_policy {
    name = "${var.name}-ecr-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "ecr:GetAuthorizationToken",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ecr:*:*:repository/${var.prefix}*"
        },
      ]
    })
  }

  inline_policy {
    name = "${var.name}-logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "logs:*",
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/${var.prefix}*",
            "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-stream:ecs/${var.prefix}*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "${var.name}-secrets"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "secretsmanager:GetSecretValue",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.prefix}-*"
        }
      ]
    })
  }

  inline_policy {
    name = "${var.name}-ssm-parameters"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.prefix}/*"
        }
      ]
    })
  }
}

# task role
resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task-role"
  assume_role_policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          Service: "ecs-tasks.amazonaws.com"
        },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })

  inline_policy {
    name = "${var.name}-task-s3-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "s3:*",
          ]
          Effect   = "Allow"
          Resource = var.s3_arn
        },
      ]
    })
  }

}

# task definition
resource "aws_ecs_task_definition" "task_def" {

  family                   = "${var.name}-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
        name: "${var.prefix}-${var.name}",
        image: "${var.repo}",
        environment: [
          {
            name: "AWS_REGION",
            value: "${var.aws_region}"
          },
          {
            name: "S3_BUCKET",
            value: var.s3_bucket
          },
        ],
        secrets: [
          {
            name: "DB_USERNAME",
            valueFrom: "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.prefix}-postgres-credentials:DB_USERNAME::"
          },
          {
            name: "DB_PASSWORD",
            valueFrom: "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.prefix}-postgres-credentials:DB_PASSWORD::"
          },
          {
            name: "DB_HOST",
            valueFrom: "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.prefix}/postgres/DB_HOST"
          },
          {
            name: "DB_NAME",
            valueFrom: "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.prefix}/postgres/DB_NAME"
          },
          {
            name: "DB_PORT",
            valueFrom: "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.prefix}/postgres/DB_PORT"
          }
        ],
        logConfiguration: {
            logDriver: "awslogs",
            secretOptions: null,
            options: {
              awslogs-group: "/${var.prefix}/${var.name}",
              awslogs-region: "${var.aws_region}",
              awslogs-stream-prefix: "ecs",
              awslogs-datetime-format: "%Y-%m-%d %H:%M:%S%L"
            }
        },
        portMappings: [
          {
            containerPort: "${var.port}",
            hostPort: "${var.port}"
          }
        ]
      }
    ]
  )

}
