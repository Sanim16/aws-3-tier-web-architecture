resource "aws_lb_target_group" "apptiertg" {
  name     = "apptiertargetgroup"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_3_tier_architecture.id

  health_check {
    protocol = "HTTP"
    path     = "/health"
  }
}

resource "aws_lb" "app_tier_internal_lb" {
  name               = "app-tier-internal-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal-lb-sg.id]
  subnets            = [aws_subnet.Private-App-Subnet-AZ-1.id, aws_subnet.Private-App-Subnet-AZ-2.id]
}

resource "aws_lb_listener" "app_tier_internal_lb" {
  load_balancer_arn = aws_lb.app_tier_internal_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apptiertg.arn
  }
}

resource "aws_launch_template" "app_tier" {
  name = "app_tier"

  image_id      = var.app_tier_ami
  instance_type = "t2.micro"

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_role_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.private-instance-sg.id]
}

resource "aws_autoscaling_group" "app_tier" {
  name                = "app_tier_asg"
  vpc_zone_identifier = [aws_subnet.Private-App-Subnet-AZ-1.id, aws_subnet.Private-App-Subnet-AZ-2.id]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.apptiertg.arn]

  launch_template {
    id      = aws_launch_template.app_tier.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "webtiertg" {
  name     = "webtiertargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_3_tier_architecture.id

  health_check {
    protocol = "HTTP"
    path     = "/health"
  }
}

resource "aws_lb" "web_tier_external_lb" {
  name               = "web-tier-external-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internet-facing-lb-sg.id]
  subnets            = [aws_subnet.Public-Web-Subnet-AZ-1.id, aws_subnet.Public-Web-Subnet-AZ-2.id]
}

resource "aws_lb_listener" "web_tier_external_lb" {
  load_balancer_arn = aws_lb.web_tier_external_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtiertg.arn
  }
}

resource "aws_launch_template" "web_tier" {
  name = "web_tier"

  image_id      = var.web_tier_ami
  instance_type = "t2.micro"

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_role_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.web-tier-sg.id]
}

resource "aws_autoscaling_group" "web_tier" {
  name                = "webtierasg"
  vpc_zone_identifier = [aws_subnet.Public-Web-Subnet-AZ-1.id, aws_subnet.Public-Web-Subnet-AZ-2.id]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.webtiertg.arn]


  launch_template {
    id      = aws_launch_template.web_tier.id
    version = "$Latest"
  }
}
