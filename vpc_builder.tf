# Terraform Settings Block
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.21"
        }
    }
}

# Provider Block
provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "dhruv_vpc" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = var.vpc_name
    }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.dhruv_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.dhruv_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "dhruv_igw" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dhruv-igw"
  }
}

resource "aws_eip" "nat_eip" {
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dhruv_igw]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.dhruv_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dhruv_igw.id
  }

  tags = {
    Name = "Public_rt"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.dhruv_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private_rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}