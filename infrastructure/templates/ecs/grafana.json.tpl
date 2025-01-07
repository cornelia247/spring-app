[
   {
      "essential": true,
      "name": "${ENV}-${PROJECT_NAME}-grafana",
      "image": "grafana/grafana:latest",
      "cpu": ${FARGATE_CPU},
      "memory": ${FARGATE_MEMORY},
      "portMappings": [
         {
            "containerPort": 3000,
            "hostPort": 3000,
            "protocol": "tcp"
         }
      ],
      "logConfiguration": {
         "logDriver": "awslogs",
         "options": {
            "awslogs-group": "${CLOUDWATCH_GROUP}",
            "awslogs-region": "${REGION}",
            "awslogs-stream-prefix": "grafana"
         }
      },
      "environment": [
         {
            "name": "GF_SECURITY_ADMIN_USER",
            "value": "${GRAFANA_ADMIN_USER}"
         },
         {
            "name": "GF_SECURITY_ADMIN_PASSWORD",
            "value": "${GRAFANA_ADMIN_PASSWORD}"
         }
      ],
      "mountPoints": [
         {
            "sourceVolume": "${SOURCE_VOLUME}",
            "containerPath": "/etc/grafana/provisioning"
         }
      ]
   }
]