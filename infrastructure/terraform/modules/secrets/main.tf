resource "aws_secretsmanager_secret" "db_username_secret" {
  name = "${var.prefix}-db-username"
}

resource "aws_secretsmanager_secret_version" "db_username_version" {
  secret_id     = aws_secretsmanager_secret.db_username_secret.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "db_password_secret" {
  name = "${var.prefix}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret" "db_host_secret" {
  name = "${var.prefix}-db-host"
}

resource "aws_secretsmanager_secret_version" "db_host_version" {
  secret_id     = aws_secretsmanager_secret.db_host_secret.id
  secret_string = var.db_host
}

resource "aws_secretsmanager_secret" "db_name_secret" {
  name = "${var.prefix}-db-name"
}

resource "aws_secretsmanager_secret_version" "db_name_version" {
  secret_id     = aws_secretsmanager_secret.db_name_secret.id
  secret_string = var.db_name
}

# Outputs of secret ARNs if needed
output "db_username_secret_arn" {
  value = aws_secretsmanager_secret.db_username_secret.arn
}