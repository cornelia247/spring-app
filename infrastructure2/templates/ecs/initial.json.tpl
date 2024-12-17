[
   {
      "essential": true,
      "name":"${ENV}-${PROJECT_NAME}-app",
      "image":"${APP_IMAGE}",
      "cpu": ${FARGATE_CPU},
      "memory": ${FARGATE_MEMORY},
      "portMappings":[
         {
            "containerPort":${APP_PORT},
            "hostPort":${APP_PORT}
         }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${CLOUDWATCH_GROUP}",
            "awslogs-region": "${REGION}",
            "awslogs-stream-prefix": "ecs"
          }
        },
      "environment":[
         {
            "name":"SPRING_DATASOURCE_URL",
            "value":"${POSTGRES_URL}"
         },
         {
            "name":"SPRING_DATASOURCE_USERNAME",
            "value":"${POSTGRES_USERNAME}"
         },
         {
            "name":"SPRING_DATASOURCE_PASSWORD",
            "value":"${POSTGRES_PASSWORD}"
         }
      ]
   }
]