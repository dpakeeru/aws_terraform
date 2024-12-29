resource "aws_lb_target_group" "webserver_targets" {
  name       = "web-server-target-group"
  vpc_id     = aws_vpc.dhruv_vpc.id
  port       = 80
  protocol   = "HTTP"
  slow_start = 0
  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "web_server_target_group"
  }
}

resource "aws_lb_target_group_attachment" "web_server_attachment" {
  target_group_arn = aws_lb_target_group.webserver_targets.arn
  target_id = aws_instance.web_server_ec2_instance[0].id
}

resource "aws_lb" "web_server_lb" {
  name = "web-server-lb"
  internal = false
  subnets = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  security_groups = [aws_security_group.internet_facing_lb_sg.id]
}

resource "aws_lb_listener" "web_server_listener" {
  load_balancer_arn = aws_lb.web_server_lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webserver_targets.arn
  }
}

resource "aws_launch_template" "web_server_launch_temp" {
  name = "web-server-launch-template"
  image_id = "ami-0c8ad58603db6faf6"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.web_tier_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name = "web-server-asg"
  max_size = 4
  min_size = 2
  health_check_grace_period = 30
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  vpc_zone_identifier = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  target_group_arns = [aws_lb_target_group.webserver_targets.arn]
  launch_template {
    id = aws_launch_template.web_server_launch_temp.id
    version = aws_launch_template.web_server_launch_temp.latest_version
  }
}

resource "aws_autoscaling_policy" "web_server_asg_policy" {
  name = "web-server-asg-policy"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
  estimated_instance_warmup = 30
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 25.0
  }
}