# Terraform Settings Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.21"
    }
  }
}

# Provider Block
provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "dhruv-terraform-state"

  tags = {
    Name = "dhruv-terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versions" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock"{
    name = "dhruv-terraform-lock"
    read_capacity = 5
    write_capacity = 5
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }
    tags = {
        Name = "terraform-lock"
    }
}