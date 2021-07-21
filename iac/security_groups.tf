resource "aws_security_group" "jenkins-master-sg" {
  name   = "jenkins-master-sg"
  vpc_id = aws_vpc.petclinic-vpc.id
  ingress {
    from_port       = 8082
    protocol        = "tcp"
    to_port         = 8082
    security_groups = [aws_security_group.jenkins-elb-sg.id]
  }
  ingress {
    from_port       = 8080
    protocol        = "tcp"
    to_port         = 8080
    security_groups = [aws_security_group.jenkins-elb-sg.id]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-master-sg"
  }
}

resource "aws_security_group" "jenkins-elb-sg" {
  name   = "jenkins-elb-sg"
  vpc_id = aws_vpc.petclinic-vpc.id
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-elb-sg"
  }
}

resource "aws_security_group" "web-elb-sg" {
  name   = "web-elb-sg"
  vpc_id = aws_vpc.petclinic-vpc.id
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-elb-sg"
  }
}

resource "aws_security_group" "web-ec2-sg" {
  name   = "web-ec2-sg"
  vpc_id = aws_vpc.petclinic-vpc.id
  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.web-elb-sg.id]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-ec2-sg"
  }

}

resource "aws_security_group" "build-sg" {
  name   = "build-sg"
  vpc_id = aws_vpc.petclinic-vpc.id
  ingress {
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
    security_groups = [aws_security_group.jenkins-master-sg.id]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "build-sg"
  }
}