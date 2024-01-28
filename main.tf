terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
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

      }
    ]
  })
}

resource "aws_iam_role" "apprunner-instance-role" {
  name = "${var.apprunner-service-role}AppRunnerInstanceRole"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.apprunner-instance-assume-policy.json
}

resource "aws_iam_policy_attachment" "ecs_secrets_attachment" {
  name       = "ECSAccessToSecretsAttachment"
  roles      = [aws_iam_role.apprunner-instance-role.name]
  policy_arn = aws_iam_policy.iam_policy_secrets.arn
}

resource "aws_vpc" "main" {
  cidr_block           = "172.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Environment        = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  count                   = 3
  map_public_ip_on_launch = true

  tags = {
    Environment        = var.environment
  }
}


resource "aws_security_group" "vpc_connector" {
  name        = "vpc-connector-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }

  tags = {
    Environment        = var.environment
  }
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "name"
  subnets            =  aws_subnet.public[*].id
  security_groups = [aws_security_group.vpc_connector.id]
  tags = {
    Environment        = var.environment
  }
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
    // source directory
  source_configuration {
    authentication_configuration {
      connection_arn = aws_apprunner_connection.formal.arn
    }
    code_repository {
      code_configuration {
        code_configuration_values {
          build_command = "cd backend/python-api && pip install -r requirements.txt"
          port          = "8000"
          runtime       = "PYTHON_3"
          start_command = "cd backend/python-api && gunicorn wsgi:app"
          runtime_environment_secrets = {
            "DATABASE_NAME" : aws_secretsmanager_secret.db_name.arn,
            "DATABASE_PASSWORD" : aws_secretsmanager_secret.db_password.arn,
            "DATABASE_URL" : aws_secretsmanager_secret.db_url.arn,
            "DATABASE_USER" : aws_secretsmanager_secret.db_user.arn,
            "PORT": 8080
          }
        }
        configuration_source = "API"
      }
      repository_url = "https://github.com/formalco/backoffice-demo"
      source_code_version {
        type  = "BRANCH"
        value = "main"
      }
    }
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }

  tags = {
    Environment = var.environment
  }
}
output "apprunner_service_url" {
  value = "https://${aws_apprunner_service.formal.service_url}"
}