resource "aws_db_subnet_group" "this" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier         = "${var.prefix}-db"
  engine             = "postgres"
  engine_version     = "14.5"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_subnet_group_name = aws_db_subnet_group.this.name
  username           = var.db_username
  password           = var.db_password
  skip_final_snapshot = true

  tags = {
    Name = "${var.prefix}-db"
  }
}

output "db_endpoint" {
  value = aws_db_instance.this.address
}