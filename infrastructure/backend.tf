terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }
  backend "s3" {
    bucket         = var.s3_bucket
    region         = "us-east-1"
    key            = "terraform/state"
    dynamodb_table = var.dynamodb_table
  }
}

provider "aws" {
  region  = var.aws_region
}