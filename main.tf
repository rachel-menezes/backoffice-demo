data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "172.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  count                   = 3
  map_public_ip_on_launch = true

  tags = {
    Name        = var.environment
  }
}


resource "aws_security_group" "vpc_connector" {
  name        = "vpc-connector-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.default]

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
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "name"
  subnets            =  aws_subnet.public[*].id
  security_groups = [aws_security_group.vpc_connector.id]
  tags = {
    Name        = var.environment
  }
}

resource "aws_apprunner_connection" "formal" {
  connection_name = "formal-github"
  provider_type   = "GITHUB"

  tags = {
    Name = var.environment
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
    Name = var.environment
  }
}
output "apprunner_service_url" {
  value = "https://${aws_apprunner_service.formal.service_url}"
}