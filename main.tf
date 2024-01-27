resource "aws_apprunner_connection" "formal" {
  connection_name = "formal-github"
  provider_type   = "GITHUB"

  tags = {
    Name = "formal-apprunner-connection"
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
    Name = "formal-apprunner-service"
  }
}