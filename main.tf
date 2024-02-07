terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}


data "aws_iam_policy_document" "apprunner-instance-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "iam_policy_secrets" {
  name        = "ECSAccessToSecrets"
  description = "Grant App runner access to secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.db_password.arn

      },
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.db_url.arn

      },
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.db_user.arn

      },
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.db_name.arn
      },
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.users.arn
      }
    ]
  })
}

resource "aws_iam_role" "apprunner-instance-role" {
  name = "${var.name}-app-runner-instance-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.apprunner-instance-assume-policy.json
}

resource "aws_iam_policy_attachment" "ecs_secrets_attachment" {
  name       = "ECSAccessToSecretsAttachment"
  roles      = [aws_iam_role.apprunner-instance-role.name]
  policy_arn = aws_iam_policy.iam_policy_secrets.arn
}
resource "aws_apprunner_connection" "formal" {
  connection_name = "formal-github"
  provider_type   = "GITHUB"

  tags = {
    Environment = var.environment
  }
}

resource "aws_apprunner_service" "formal" {
  service_name = "formal-github-demo"
  source_configuration {
    authentication_configuration {
      connection_arn = aws_apprunner_connection.formal.arn
    }
    code_repository {
      code_configuration {
        code_configuration_values {
          build_command = "python3 -m pip install -r requirements.txt"
          port          = "4000"
          runtime       = "PYTHON_311"
          start_command = "gunicorn wsgi:app"
          runtime_environment_secrets = {
            "DATABASE_NAME" : aws_secretsmanager_secret.db_name.arn,
            "DATABASE_PASSWORD" : aws_secretsmanager_secret.db_password.arn,
            "DATABASE_URL" : aws_secretsmanager_secret.db_url.arn,
            "DATABASE_USER" : aws_secretsmanager_secret.db_user.arn,
            "USERS": aws_secretsmanager_secret.users.arn
          }
        }
        configuration_source = "API"
      }
      repository_url = "https://github.com/formalco/backoffice-demo"
      source_directory = "backend/python-api"
      source_code_version {
        type  = "BRANCH"
        value = "main"
      }
    }
  }

  health_check_configuration {
    protocol = "HTTP"
    path = "/healthcheck"
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner-instance-role.arn
  }

  tags = {
    Environment = var.environment
  }
}
output "apprunner_service_url" {
  value = "https://${aws_apprunner_service.formal.service_url}"
}