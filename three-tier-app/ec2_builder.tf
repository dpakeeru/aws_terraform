resource "aws_key_pair" "my_key" {
  key_name   = var.key_pair
  public_key = file("C:\\AWS\\my-key.pub")
}


resource "aws_security_group" "web_sg" {
  name        = var.web_sg_name
  description = "Creates a secruity group for web server"
  vpc_id      = aws_vpc.dhruv_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = var.web_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = element(aws_subnet.public_subnets[*].id, count.index)
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sudo su -
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
  EOF

  tags = {
    Name = "HTTPD Server ${count.index + 1}"
  }
}
