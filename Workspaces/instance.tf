resource "aws_instance" "file_instance" {
  ami = "ami-0b4624933067d393a"
  key_name = "dhruv-key-pair-Ohio"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]

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

