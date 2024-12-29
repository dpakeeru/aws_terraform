resource "aws_security_group" "internet_facing_lb_sg" {
  name        = "internet-facing-lb-sg"
  description = "Creates a secruity group for external load balancer"
  vpc_id      = aws_vpc.dhruv_vpc.id

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

resource "aws_security_group" "web_tier_sg" {
  name        = "web-tier-sg"
  description = "Creates a secruity group for web tier"
  vpc_id      = aws_vpc.dhruv_vpc.id

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
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


  ingress {
    description = "HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    security_groups = [aws_security_group.internet_facing_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_lb_sg" {
  name        = "internal-lb-sg"
  description = "Creates a secruity group for internal load balancer"
  vpc_id      = aws_vpc.dhruv_vpc.id

  ingress {
    description = "HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    security_groups = [aws_security_group.web_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_tier_lb_sg" {
  name        = "app-tier-lb-sg"
  description = "Creates a secruity group for app server"
  vpc_id      = aws_vpc.dhruv_vpc.id

  ingress {
    description = "TCP"
    from_port   = "4000"
    to_port     = "4000"
    protocol    = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }

  ingress {
    description = "TCP"
    from_port   = "4000"
    to_port     = "4000"
    protocol    = "tcp"
    cidr_blocks = ["72.76.205.30/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_tier_lb_sg" {
  name        = "db-tier-lb-sg"
  description = "Creates a secruity group for db server"
  vpc_id      = aws_vpc.dhruv_vpc.id

  ingress {
    description = "TCP"
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    security_groups = [aws_security_group.app_tier_lb_sg.id]
  }

  ingress {
    description = "TCP"
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = ["72.76.205.30/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}