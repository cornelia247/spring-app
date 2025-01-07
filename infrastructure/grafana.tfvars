# General Environment Configuration
env                   = "" # Example: "dev", "staging", or "prod" to indicate environment type.
aws_region            = "" # Example: "us-east-1" or "us-west-2".

vpc_cidr_block        = "" # Example: "10.16.0.0/16". Plan CIDR blocks to avoid IP conflicts.

# Subnet Configuration
pub_subnet_count      = "" # Example: 2. For redundancy, use at least 2 public subnets.
pub_cidr_block        = [] # Example: ["10.16.0.0/20", "10.16.16.0/20"].

pri_subnet_count      = "" # Example: 2. Use at least 2 private subnets for high availability.
pri_cidr_block        = [] # Example: ["10.16.128.0/20", "10.16.144.0/20"].

availability_zone     = [] # Example: ["us-east-1a", "us-east-1b"]. Distribute resources across AZs.

# Project and Application Configuration
project_name          = "" # Example: "spring". Use a descriptive name for your project.
app_count             = "" # Example: 1. Start with 1 replica; scale based on load.
app_port              = "" # Example: 8080. Match the port used by your application.

fargate_cpu           = "" # Example: "256". For lightweight apps, use 256 CPU units (1 vCPU = 1024 units).
fargate_memory        = "" # Example: "512". Start with 512 MB for small apps; increase as needed.

max_capacity          = "" # Example: 3. Maximum scaling capacity for ECS service.
min_capacity          = "" # Example: 1. Minimum scaling capacity for ECS service.

# Database Configuration
engine_version        = "" # Example: "15.4". Use the latest stable version of PostgreSQL.
instance_class        = "" # Example: "db.t3.micro". Suitable for dev; use larger instances for production.
allocated_storage     = "" # Example: 20. Minimum storage in GB for development environments.

db_username           = "" # Example: "postgres". Use a strong username; "postgres" is the default.
db_name               = "" # Example: "postgres". Use the default PostgreSQL database created.
recovery_window       =  # Example:  0. Days the secret will be kept after deleting, use a higher number for production 7

