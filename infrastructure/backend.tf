terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
  backend "s3" {
    bucket         = "" # Example: "spring-time-terraform-backend-bucket". Name of the S3 bucket for state storage.
    region         = "" # Example: "us-east-1". AWS region where the S3 bucket is located.
    key            = "" # Example: "newterraform/state". Path to store the Terraform state file in the bucket.
    dynamodb_table = "" # Example: "terraform-lock-table". Name of the DynamoDB table for state locking.
}
}

provider "aws" {
  region  = "us-east-1"
}