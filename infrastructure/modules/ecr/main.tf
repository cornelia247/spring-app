resource "aws_ecr_repository" "this" {
  name                 = "${var.env}-${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  tags = {
    Name = "${var.env}-${var.project_name}-repository"
    Project = var.project_name
    Environment  = var.env
  }
}

