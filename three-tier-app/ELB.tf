/*
resource "aws_lb_target_group" "web_server_targets" {
  name       = var.webserver_target_group_name
  vpc_id     = aws_vpc.dhruv_vpc.id
  port       = 80
  protocol   = "HTTP"
  slow_start = 0
  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "target_group"
  }
}

resource "aws_lb" "lb" {
  name               = var.elb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets = [
    aws_subnet.public_subnets[0].id,
    aws_subnet.public_subnets[1].id
  ]
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_targets.arn
  }
}

resource "aws_lb_target_group_attachment" "lb_attachment1" {
  target_group_arn = aws_lb_target_group.web_server_targets.arn
  target_id        = aws_instance.ec2_instance[0].id
}

resource "aws_lb_target_group_attachment" "lb_attachment2" {
  target_group_arn = aws_lb_target_group.web_server_targets.arn
  target_id        = aws_instance.ec2_instance[1].id
}
*/