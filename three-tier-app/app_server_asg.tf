resource "aws_lb_target_group" "appserver_targets" {
  name       = "app-server-target-group"
  vpc_id     = aws_vpc.dhruv_vpc.id
  port       = 4000
  protocol   = "HTTP"
  slow_start = 0
  health_check {
    enabled             = true
    port                = 4000
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "app_server_target_group"
  }
}

resource "aws_lb_target_group_attachment" "app_server_attachment" {
  target_group_arn = aws_lb_target_group.appserver_targets.arn
  target_id = aws_instance.app_server_ec2_instance[0].id
}

resource "aws_lb" "app_server_lb" {
  name = "app-server-lb"
  internal = true 
  subnets = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  security_groups = [aws_security_group.internal_lb_sg.id]
}

resource "aws_lb_listener" "app_server_listener" {
  load_balancer_arn = aws_lb.app_server_lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.appserver_targets.arn
  }
}

resource "aws_launch_template" "app_server_launch_temp" {
  name = "app-server-launch-template"
  image_id = "ami-079810b56be5843d0"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.app_tier_lb_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

resource "aws_autoscaling_group" "app_server_asg" {
  name = "app-server-asg"
  max_size = 4
  min_size = 2
  health_check_grace_period = 30
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  vpc_zone_identifier = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  target_group_arns = [aws_lb_target_group.appserver_targets.arn]
  launch_template {
    id = aws_launch_template.app_server_launch_temp.id
    version = aws_launch_template.app_server_launch_temp.latest_version
  }
}

resource "aws_autoscaling_policy" "app_server_asg_policy" {
  name = "app-server-asg-policy"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app_server_asg.name
  estimated_instance_warmup = 30
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 25.0
  }
}