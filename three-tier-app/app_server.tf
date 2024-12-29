resource "aws_instance" "app_server_ec2_instance" {
  count                       = length(var.private_subnet_cidrs)
  ami                         = var.web_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.app_tier_lb_sg.id]
  subnet_id                   = element(aws_subnet.private_subnets[*].id, count.index)
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<EOF
#!/bin/bash
sudo su
dnf update -y
dnf install mariadb105 -y
export HOME=~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[-s "$NVM_DIR/nvm.sh"] && \. "$NVM_DIR/nvm.sh"
source ~/.bashrc
nvm install 16
nvm use 16
npm install -g pm2
cd ~/
aws s3 cp s3://dhruv-three-tier-bucket/app-tier/ app-tier --recursive
cd ~/app-tier
npm install
pm2 start index.js
pm2 list
pm2 logs
pm2 startup
pm2 save

  EOF

  tags = {
    Name = "App Server ${count.index + 1}"
  }
}