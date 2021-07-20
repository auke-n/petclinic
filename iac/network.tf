resource "aws_vpc" "petclinic-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "petclinic-vpc"
  }
}

resource "aws_internet_gateway" "petclinic-gw" {
  vpc_id = aws_vpc.petclinic-vpc.id

  tags = {
    Name = "petclinic-igw"
  }
}

resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.petclinic-gw.id
}

resource "aws_subnet" "petclinic-pbl1" {
  cidr_block        = "172.16.0.0/24"
  vpc_id            = aws_vpc.petclinic-vpc.id
  availability_zone = "eu-central-1a"

  tags = {
    Name = "petclinic-pbl1"
  }
}

resource "aws_subnet" "petclinic-pbl2" {
  cidr_block        = "172.16.1.0/24"
  vpc_id            = aws_vpc.petclinic-vpc.id
  availability_zone = "eu-central-1b"

  tags = {
    Name = "petclinic-pbl2"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.petclinic-vpc.id

  tags = {
    Name = "petclinic-public-rt"
  }
}

resource "aws_route_table_association" "a1" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.petclinic-pbl1.id
}

resource "aws_route_table_association" "a2" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.petclinic-pbl2.id
}