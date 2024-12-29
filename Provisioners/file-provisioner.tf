resource "aws_instance" "file_instance" {
  ami = "ami-0b4624933067d393a"
  key_name = "dhruv-key-pair-Ohio"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
}

resource "null_resource" "local_command" {
  depends_on = [ aws_instance.file_instance ]

  provisioner "local-exec" {
    command = "powershell.exe -Command \"Write-Output 'EC2 instance created with ID: ${aws_instance.file_instance.id}'\""
  }
}

resource "aws_security_group" "instance_sg" {
  name = "instance-security-group"
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


resource "null_resource" "remote_command" {
  depends_on = [ aws_instance.file_instance ]

  provisioner "remote-exec" {
    inline = [ 
    "sudo yum update -y",
    "sudo yum install httpd -y",
    "sudo systemctl start httpd.service",
    "sudo systemctl enable httpd.service"
     ]

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:\\AWS\\dhruv-key-pair-Ohio.pem")
    host = aws_instance.file_instance.public_ip
  }
  }
}

resource "null_resource" "file_copy_command" {
  depends_on = [ aws_instance.file_instance ]

  provisioner "file" {
    source = "C:\\AWS\\aws-three-tier-web-app\\README.md"
    destination = "/tmp/README.md"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:\\AWS\\dhruv-key-pair-Ohio.pem")
    host = aws_instance.file_instance.public_ip
  }
}