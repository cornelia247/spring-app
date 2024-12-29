# General Environment Configuration
env                   = "eks" # Example: "dev", "staging", or "prod" to indicate environment type.
aws_region            = "us-east-1" # Example: "us-east-1" or "us-west-2".

vpc_cidr_block        = "10.16.0.0/16" # Example: "10.16.0.0/16". Plan CIDR blocks to avoid IP conflicts.

# Subnet Configuration
pub_subnet_count      = "2" # Example: 2. For redundancy, use at least 2 public subnets.
pub_cidr_block        = ["10.16.0.0/20", "10.16.16.0/20"] # Example: ["10.16.0.0/20", "10.16.16.0/20"].

pri_subnet_count      = "2" # Example: 2. Use at least 2 private subnets for high availability.
pri_cidr_block        = ["10.16.128.0/20", "10.16.144.0/20"] # Example: ["10.16.128.0/20", "10.16.144.0/20"].

availability_zone     = ["us-east-1a", "us-east-1b"] # Example: ["us-east-1a", "us-east-1b"]. Distribute resources across AZs.

# Project and Application Configuration
project_name          = "spring" # Example: "spring". Use a descriptive name for your project.

desired_size          = "1" # Example: 3. Maximum scaling capacity for EKS service.
max_size              = "2" # Example: 3. Maximum scaling capacity for EKS service.
min_size              = "1" # Example: 1. Minimum scaling capacity for EKS service.

# Database Configuration
engine_version        = "15.4" # Example: "15.4". Use the latest stable version of PostgreSQL.
instance_class        = "db.t3.micro" # Example: "db.t3.micro". Suitable for dev; use larger instances for production.
allocated_storage     = "20" # Example: 20. Minimum storage in GB for development environments.

db_username           = "postgres" # Example: "postgres". Use a strong username; "postgres" is the default.
db_name               = "postgres" # Example: "postgres". Use the default PostgreSQL database created.