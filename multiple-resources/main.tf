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