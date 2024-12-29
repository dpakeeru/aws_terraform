resource "aws_instance" "web_server_ec2_instance" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = var.web_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.web_tier_sg.id]
  subnet_id                   = element(aws_subnet.public_subnets[*].id, count.index)
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sudo su -
dnf update -y
export HOME=~
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[-s "$NVM_DIR/nvm.sh"] && \. "$NVM_DIR/nvm.sh"
source ~/.bashrc
nvm install 16
nvm use 16
cd ~/
aws s3 cp s3://dhruv-three-tier-bucket/web-tier/ /home/ec2-user/web-tier --recursive
cd /home/ec2-user/web-tier
npm install
npm run build
dnf install -y nginx
cd /etc/nginx
sudo rm nginx.conf
sudo aws s3 cp s3://dhruv-three-tier-bucket/nginx.conf .
sudo chmod -R 755 /home/ec2-user
sudo systemctl start nginx
sudo systemctl enable nginx
sudo service nginx restart
  EOF

  tags = {
    Name = "Web Server ${count.index + 1}"
  }
}