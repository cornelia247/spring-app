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
  grafana_datasources = <<-EOT
    apiVersion: 1
    datasources:
      - name: AWS CloudWatch
        type: cloudwatch
        access: proxy
        jsonData:
          defaultRegion: ${var.aws_region}
  EOT

  grafana_dashboard = <<-EOT
    {
      "id": null,
      "title": "ECS Logs Dashboard",
      "panels": [
        {
          "title": "Application Logs",
          "type": "logs",
          "targets": [
            {
              "region": "${var.aws_region}",
              "logGroupNames": ["/ecs/${aws_ecs_service.app.name}"],
              "query": "fields @timestamp, @message | sort @timestamp desc | limit 20"
            }
          ]
        }
      ]
    }
  EOT

}


resource "random_password" "random" {
  length           = 5
  special          = false
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


resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

//GRAFANA SECRETS
resource "aws_secretsmanager_secret" "grafana_admin_password" {
  name = "${var.env}-${var.project_name}-grafana-credentials"
  description = "Stores grafana credentials"
  recovery_window_in_days = 0
  tags = {
    Name = "${var.env}-${var.project_name}-grafana-credentials"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_secretsmanager_secret_version" "grafana_admin_password_value" {
  secret_id     = aws_secretsmanager_secret.grafana_admin_password.id
  secret_string = random_password.random.result # Replace this with secure input.
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



resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "grafana-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana:latest"
      essential = true
      portMappings = [{ containerPort = 3000 }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = "admin" }
      ]
      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD",
          valueFrom = aws_secretsmanager_secret.grafana_admin_password.arn
        }
      ]
      mountPoints = [
        { sourceVolume = "datasources", containerPath = "/etc/grafana/provisioning/datasources" },
        { sourceVolume = "dashboards", containerPath = "/etc/grafana/provisioning/dashboards" }
      ]
    }
  ])

  volume {
    name = "datasources"
    docker_volume_configuration {
      scope         = "task"
      autoprovision = true
      driver_opts = { "content" = local.grafana_datasources }
    }
  }

  volume {
    name = "dashboards"
    docker_volume_configuration {
      scope         = "task"
      autoprovision = true
      driver_opts = { "content" = local.grafana_dashboard }
    }
  }
}

resource "aws_ecs_service" "grafana_service" {
  name            = "${var.env}-grafana-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.grafana_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.grafana_tg
    container_name   = "grafana"
    container_port   = 3000
  }
}

