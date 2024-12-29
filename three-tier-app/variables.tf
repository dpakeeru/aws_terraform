variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_name" {
  type    = string
  default = "dhruv_vpc"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Values of Public Subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Values of Private Subnet CIDRs"
}

variable "availability_zone" {
  type        = list(string)
  description = "AZs"
}

variable "web_ami" {
  type        = string
  description = "What AMI is being used"
}

variable "instance_type" {
  type        = string
  description = "Type of Instance"
}

variable "key_pair" {
  type = string
}

variable "web_sg_name" {
  type = string
}

variable "webserver_target_group_name" {
  type = string
}

variable "elb_name" {
  type = string
}