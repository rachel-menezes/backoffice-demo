resource "aws_secretsmanager_secret" "db_name" {
  name = "${var.name}-db-name"
}

resource "aws_secretsmanager_secret_version" "db_name" {
  secret_id     = aws_secretsmanager_secret.db_name.id
  secret_string = var.database_name
}

resource "aws_secretsmanager_secret" "db_url" {
  name = "${var.name}-db-url"
}

resource "aws_secretsmanager_secret_version" "db_url" {
  secret_id     = aws_secretsmanager_secret.db_url.id
  secret_string = var.database_url
}

resource "aws_secretsmanager_secret" "db_user" {
  name = "${var.name}-db-user"
}

resource "aws_secretsmanager_secret_version" "db_user" {
  secret_id     = aws_secretsmanager_secret.db_user.id
  secret_string = var.database_user
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.name}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.database_password
}

resource "aws_secretsmanager_secret" "port" {
  name = "${var.name}-port"
}

resource "aws_secretsmanager_secret_version" "port" {
  secret_id     = aws_secretsmanager_secret.port.id
  secret_string = 8080
}

resource "aws_secretsmanager_secret" "users" {
  name = "${var.name}-users"
}

resource "aws_secretsmanager_secret_version" "users" {
  secret_id     = aws_secretsmanager_secret.users.id
  secret_string = var.users
}
