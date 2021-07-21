resource "aws_lb" "jenkins-lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins-elb-sg.id]
  subnets            = [aws_subnet.petclinic-pbl1.id, aws_subnet.petclinic-pbl2.id]

  tags = {
    Name = "jenkins-master-alb"
  }
}

resource "aws_lb_target_group" "jenkins-master-tg" {
  name        = "jenkins-master-tg"
  port        = 8082
  target_type = "instance"
  vpc_id      = aws_vpc.petclinic-vpc.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/login"
    port     = 8082
    protocol = "HTTP"
    matcher  = "200-299"
  }

  tags = {
    Name = "jenkins-tg"
  }
}

resource "aws_lb_target_group_attachment" "jenkins-master-attach" {
  target_group_arn = aws_lb_target_group.jenkins-master-tg.arn
  target_id        = aws_instance.jenkins-master.id
  port             = 8082
}

resource "aws_lb_listener" "jenkins-master-https" {
  load_balancer_arn = aws_lb.jenkins-lb.arn
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins-https.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-master-tg.arn
  }

  tags = {
    Name = "jenkins-listener"
  }
}

resource "aws_lb" "web-server-lb" {
  name               = "web-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-elb-sg.id]
  subnets            = [aws_subnet.petclinic-pbl1.id, aws_subnet.petclinic-pbl2.id]

  tags = {
    Name = "web-server-lb"
  }
}

resource "aws_lb_target_group" "web-server-tg" {
  name        = "app-lb-tg"
  port        = 80
  target_type = "instance"
  vpc_id      = aws_vpc.petclinic-vpc.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/login"
    port     = 80
    protocol = "HTTP"
    matcher  = "200-299"
  }

  tags = {
    Name = "web-server-tg"
  }
}

resource "aws_lb_target_group_attachment" "web-server-attach" {
  target_group_arn = aws_lb_target_group.web-server-tg.arn
  target_id        = aws_instance.web-server.id
  port             = 80
}

resource "aws_lb_listener" "web-server-https" {
  load_balancer_arn = aws_lb.web-server-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.petclinic-https.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server-tg.arn
    }
  tags = {
    Name = "web-server-listener"
  }
}