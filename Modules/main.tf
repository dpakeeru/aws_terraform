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

module "EC2" {
  source = "C:\\AWS\\aws_terraform\\Modules\\EC2"

  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  env = var.env
}