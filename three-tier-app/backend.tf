terraform {
  backend "s3" {
    bucket         = "dhruv-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "dhruv-terraform-lock"
    encrypt        = true
  }
}