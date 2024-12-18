env                   = "dev" # insert name of environment e.g "dev", "staging"
aws_region            = "us-east-1"
vpc_cidr_block        = "10.16.0.0/16"
pub_subnet_count      = 2 
pub_cidr_block        = ["10.16.0.0/20", "10.16.16.0/20"]
availability_zone = ["us-east-1a", "us-east-1b"]
pri_subnet_count      = 2
pri_cidr_block        = ["10.16.128.0/20", "10.16.144.0/20"]
project_name = "spring"
app_count = 1
app_port = 8080
fargate_cpu = "256"
fargate_memory = "512"
max_capacity = 3
min_capacity = 1


#DB
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_username = "postgres"
  db_name = "postgres"



