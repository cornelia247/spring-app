env                   = "dev" # insert name of environment e.g "dev", "staging"
aws_region            = "us-east-1"
vpc_cidr_block        = "10.16.0.0/16"
pub_subnet_count      = 2 
pub_cidr_block        = ["10.16.0.0/20", "10.16.16.0/20"]
availability_zone = ["us-east-1a", "us-east-1b"]
pri_subnet_count      = 2
pri_cidr_block        = ["10.16.128.0/20", "10.16.144.0/20"]
project_name = "spring"

# EKS
ondemand_instance_types    = "t3a.medium"
desired_capacity_on_demand = "1"
min_capacity_on_demand     = "1"
max_capacity_on_demand     = "2"
cluster_version = 1.29


#DB
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_username = "postgres"
  db_name = "spring-db"

#backend
  s3_bucket = "spring-time-terraform-backend-bucket"
  dynamodb_table = "terraform-lock-table"

