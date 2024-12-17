data "aws_secretsmanager_secret_version" "retrieved" {
  secret_id = var.db_credentials
}
locals {
  secret_json = jsondecode(data.aws_secretsmanager_secret_version.retrieved.secret_string)
  rendered_template = templatefile("./templates/ecs/initial.json.tpl",{
    ENV      = var.env
    PROJECT_NAME = var.project_name
    APP_PORT       = var.app_port
    APP_IMAGE    = var.app_image
    FARGATE_MEMORY = var.fargate_memory
    FARGATE_CPU     = var.fargate_cpu
    CLOUDWATCH_GROUP = "/ecs/${var.env}-${var.project_name}-app"
    REGION = var.aws_region
    POSTGRES_URL = local.secret_json["db_url"]
    POSTGRES_USERNAME = local.secret_json["username"]
    POSTGRES_PASSWORD = local.secret_json["password"]

  })
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource "aws_ecs_cluster" "main" {
  name = "${var.env}-${var.project_name}-ecs"
  tags = {
    Name = "${var.env}-${var.project_name}-ecs"
    Project = var.project_name
    Environment  = var.env
  }
}

# data "template_file" "app" {
#   template = file("../templates/ecs/initial.json.tpl")

#   vars = {
#     ENV      = var.env
#     PROJECT_NAME = var.project_name
#     app_port       = var.app_port
#     APP_IMAGE    = var.app_image
#     FARGATE_MEMORY = var.fargate_memory
#     FARGATE_CPU     = var.fargate_cpu
#     CLOUDWATCH_GROUP = "/ecs/${var.env}-${var.project_name}-app"
#     REGION = var.aws_region
#     POSTGRES_URL = local.secret_json["db_url"]
#     POSTGRES_USERNAME = local.secret_json["username"]
#     POSTGRES_PASSWORD = local.secret_json["password"]

#   }
# }

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}-${var.project_name}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = local.rendered_template
}

resource "aws_ecs_service" "main" {
  name            = "${var.env}-${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_sg_id]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_tg
    container_name   = "${var.env}-${var.project_name}-app"
    container_port   = var.app_port
  }

  lifecycle {
    ignore_changes = [task_definition] // ignoring task definitions
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}
