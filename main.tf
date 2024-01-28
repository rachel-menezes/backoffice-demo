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

data "aws_iam_policy_document" "apprunner-instance-role-policy" {
  statement {
    actions = ["ssm:GetParameter"]
    effect = "Allow"
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter${data.aws_ssm_parameter.dbpassword.name}"]
  }
}

resource "aws_iam_role" "apprunner-instance-role" {
  name = "${var.apprunner-service-role}AppRunnerInstanceRole"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.apprunner-instance-assume-policy.json
}

resource "aws_iam_policy" "Apprunner-policy" {
  name = "Apprunner-getSSM"
  policy = data.aws_iam_policy_document.apprunner-instance-role-policy.json
}

resource "aws_iam_role_policy_attachment" "apprunner-instance-role-attachment" {
  role = aws_iam_role.apprunner-instance-role.name
  policy_arn = aws_iam_policy.Apprunner-policy.arn
}

resource "aws_iam_role_policy_attachment" "apprunner-instance-role-xray-attachment" {
  role = aws_iam_role.apprunner-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess" 
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
            "DATABASE_NAME" : var.database_name,
            "DATABASE_PASSWORD" : var.database_password,
            "DATABASE_URL" : var.database_url,
            "DATABASE_USER" : var.database_user,
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