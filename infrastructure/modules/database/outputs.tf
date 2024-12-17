output "db_endpoint" {
    value = aws_db_instance.this.address
}
output "db_credentials" {
  value = aws_secretsmanager_secret_version.this.arn
}