data "aws_secretsmanager_secret_version" "retrieved" {
  secret_id = var.db_credentials
}
data "aws_secretsmanager_secret_version" "grafana" {
  secret_id = aws_secretsmanager_secret.this.arn
  depends_on = [ aws_secretsmanager_secret_version.this ]
}
locals {
  secret_json = jsondecode(data.aws_secretsmanager_secret_version.retrieved.secret_string)
  secret_grafana_json = jsondecode(data.aws_secretsmanager_secret_version.grafana.secret_string)
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
  rendered_grafana_template = templatefile("./templates/ecs/grafana.json.tpl",{
    ENV      = var.env
    PROJECT_NAME = var.project_name
    FARGATE_MEMORY = var.fargate_memory
    FARGATE_CPU     = var.fargate_cpu
    CLOUDWATCH_GROUP = "/ecs/${var.env}-${var.project_name}-grafana"
    REGION = var.aws_region
    GRAFANA_ADMIN_USER = local.secret_grafana_json["username"]
    GRAFANA_ADMIN_PASSWORD = local.secret_grafana_json["password"]
    SOURCE_VOLUME = "grafana-efs"

  })

}

resource "random_password" "password" {
  length           = 5
  special          = false
}

resource "aws_secretsmanager_secret" "this" {
  name        = "${var.env}-${var.project_name}-grafana-password"
  description = "Stores grafana credentials for ${var.env}-${var.project_name}-grafana"
  recovery_window_in_days = var.recovery_window
  tags = {
    Name = "${var.env}-${var.project_name}-grafana-password"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.password.result
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

resource "aws_iam_role_policy" "ecs_assume_self" {
  name = "ecs-assume-self-policy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.ecs_task_execution_role.arn
      }
    ]
  })
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


resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy" "ecs_efs_access" {
  name = "ecs-efs-access-policy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets"
        ],
        Effect   = "Allow",
        Resource = var.efs_file_system_arn
      }
    ]
  })
}



resource "aws_ecs_cluster" "main" {
  name = "${var.env}-${var.project_name}-ecs"
  tags = {
    Name = "${var.env}-${var.project_name}-ecs"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}-${var.project_name}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = local.rendered_template
}

resource "aws_ecs_service" "app" {
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







//GRAFANA

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = local.rendered_grafana_template # External JSON for container config

  volume {
    name = "grafana-efs"

    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      root_directory = "/grafana"
    }
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.env}-${var.project_name}-grafana-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_sg_id]
    assign_public_ip = true

  }
  load_balancer {
    target_group_arn = var.alb_grafana_tg
    container_name   = "${var.env}-${var.project_name}-grafana"
    container_port   = 3000
  }
  lifecycle {
    ignore_changes = [task_definition] 
  }
}