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