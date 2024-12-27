variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "aws_region" {
    type = string
    default = "us-east-2"
}

variable "vpc_name" {
    type = string
    default = "dhruv_vpc"
}

variable "public_subnet_cidrs" {
  type = list(string)
  description = "Values of Public Subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type = list(string)
  description = "Values of Private Subnet CIDRs"
}