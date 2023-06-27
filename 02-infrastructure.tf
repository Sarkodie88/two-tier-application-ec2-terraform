# Create a security group for the instances
resource "aws_security_group" "my_security_group" {
  name_prefix = "my-security-group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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


resource "aws_instance" "my_instance" {
  for_each = var.instances

  ami                  = each.value.ami
  instance_type        = each.value.instance_type
  subnet_id            = aws_subnet.my_private_subnet.id
  tags                 = each.value.tags
  iam_instance_profile = aws_iam_instance_profile.my_instance_profile.name
  security_groups      = [aws_security_group.my_security_group.id]
  user_data            = <<-EOF
              #!/bin/bash
              sudo apt -y update
              sudo apt install -y nginx
              sudo systemctl enable nginx
              EOF

  # lifecycle {
  #   # prevent_destroy = true
  #   ignore_changes = [aws_instance.my_instance]
  # }
}


resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my-instance-profile-2"
  role = aws_iam_role.instance_profile_my_role.name
}


# It will create the target group
resource "aws_lb_target_group" "target_groups" {
  for_each = var.target_groups

  name        = each.value.name
  port        = each.value.port
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    timeout             = var.health_check["timeout"]
    path                = var.health_check["path"]
  }
}



# Attach instances to their corresponding target groups
resource "aws_lb_target_group_attachment" "ec2_attachments" {
  for_each = var.target_groups

  target_group_arn = aws_lb_target_group.target_groups[each.key].arn
  target_id        = aws_instance.my_instance[each.value.target_instance].id

}


# resource "aws_lb_target_group_attachment" "attachments" {
#   for_each          = aws_lb_target_group.target_groups

#   target_group_arn  = each.value.arn
#   target_id         = aws_instance.my_instance[each.key]
#   port              = each.value.port

#   target_group_arn = aws_lb_target_group.target_groups["${each.key}-target-group"].arn
#   target_id        = aws_instance.my_instance[each.key].id

# }

resource "aws_security_group" "alb_security_group" {
  name_prefix = "alb-security-group"
  vpc_id      = aws_vpc.my_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
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


resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [aws_subnet.my_public_subnet.id, aws_subnet.my_public_subnet_2.id]
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups["my-instance-1-target-group"].arn
  }
}


# path based routing examples
resource "aws_lb_listener_rule" "static_and_media" {
  listener_arn = aws_lb_listener.my_listener.arn
  # priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups["my-instance-2-target-group"].arn
  }

  condition {
    path_pattern {
      values = ["/app1/*"]
    }
  }

}


# # Create an SSL certificate for the load balancer
# resource "aws_acm_certificate" "adom_sarkodie_cert" {
#   domain_name       = "adomsarkodie.com"
#   validation_method = "DNS"

#   tags = {
#     Name = "adom-sarkodie-cert"
#   }
# }

# resource "aws_acm_certificate_validation" "adom_sarkodie_cert_validation" {
#   certificate_arn = aws_acm_certificate.adom_sarkodie_cert.arn

#   timeouts {
#     create = "30m"
#   }
# }


# # Create a listener for HTTPS traffic on port 443
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.my_load_balancer.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate_validation.adom_sarkodie_cert_validation.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_groups["my-instance-2-target-group"].arn
#   }
# }



