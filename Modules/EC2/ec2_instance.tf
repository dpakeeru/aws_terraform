data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default_vpc.id ]
  }
}

data "aws_subnet" "first_subnet" {
  id =data.aws_subnets.default_subnets.ids[0]
}

resource "aws_instance" "file_instance" {
  ami = var.ami
  key_name = var.key_name
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
  subnet_id = data.aws_subnet.first_subnet.id

  tags = {
    Environment = var.env
    Name = "${var.env}-instance"
  }
}

resource "aws_security_group" "instance_sg" {
  name = "${var.env}-instance-security-group"
  description = "Security group for instance"

  ingress {
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

