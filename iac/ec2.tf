resource "aws_instance" "jenkins-master" {
  ami                         = "ami-00f22f6155d6d92c5"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.petclinic-pbl1.id
  key_name                    = "Frankfurt"
  vpc_security_group_ids      = [aws_security_group.jenkins-master-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  user_data                   = file("config/jenkins_master.sh")

  tags = {
    Name = "jenkins-master"
  }
  lifecycle {
    ignore_changes = [public_ip, public_dns]
  }
}

resource "aws_instance" "web-server" {
  ami                         = "ami-00f22f6155d6d92c5"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.petclinic-pbl2.id
  key_name                    = "Frankfurt"
  vpc_security_group_ids      = [aws_security_group.web-ec2-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
//  user_data                   = file("config/web-server.sh")

  tags = {
    Name = "web-server"
  }
  lifecycle {
    ignore_changes = [public_ip, public_dns]
  }
}

resource "aws_instance" "build-server" {
  ami                         = "ami-00f22f6155d6d92c5"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.petclinic-pbl1.id
  key_name                    = "Frankfurt"
  vpc_security_group_ids      = [aws_security_group.build-sg.id, aws_security_group.jenkins-master-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
//  user_data                   = file("config/build_server.sh")

  tags = {
    Name = "build-server"
  }
  lifecycle {
    ignore_changes = [public_ip, public_dns, instance_state]
  }
}

