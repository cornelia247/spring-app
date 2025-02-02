
# Generate a random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>?~"
}

# Fetch the DB credentials from Secrets Manager
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.this.arn

  depends_on = [ aws_secretsmanager_secret_version.this ]
}

# Database Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.env}-${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.env}-${var.project_name}-db-subnet-group"
    Project = var.project_name
    Environment  = var.env
  }
}


# PostgreSQL Database
resource "aws_db_instance" "this" {
  identifier           = "${var.env}-${var.project_name}-db"
  engine               = "postgres"
  engine_version       = var.engine_version
  vpc_security_group_ids = [var.db_sg_id]
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  db_subnet_group_name = aws_db_subnet_group.this.name
  username             = var.db_username
  password             = random_password.db_password.result
  # publicly_accessible    = true

  skip_final_snapshot  = true

  tags = {
    Name = "${var.env}-${var.project_name}-db"
    Project = var.project_name
    Environment  = var.env
  }
}

# Secrets Manager
resource "aws_secretsmanager_secret" "this" {
  name        = "${var.env}-${var.project_name}-db-credentials"
  description = "Stores database credentials for ${var.env}-${var.project_name}-db"
  recovery_window_in_days = var.recovery_window
  tags = {
    Name = "${var.env}-${var.project_name}-db-credentials"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    db_host  = aws_db_instance.this.address
    db_name = var.db_name
    db_url   = format(
      "jdbc:postgresql://%s:%s/%s",
      aws_db_instance.this.address,
      aws_db_instance.this.port,
      var.db_name
    )
  })
}



