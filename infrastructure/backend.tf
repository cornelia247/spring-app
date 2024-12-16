terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
  backend "s3" {
    bucket         = "spring-time-terraform-backend-bucket"
    region         = "us-east-1"
    key            = "terraform/state"
    dynamodb_table = "terraform-lock-table"

  }
}

provider "aws" {
  region  = "us-east-1"
}