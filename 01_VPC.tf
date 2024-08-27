terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true #To display IPv4 DNS
  tags = {
    Name        = "${var.vpc_cidr_name}"
    environment = "${var.environment}"
  }
}

############# Public Subnet, IGW, RT, RTAssociation ##################
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_cidr_name}-public-subnet-${count.index + 1}"
  }
}
########### internet_gateway ########### 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.IGW_name}"
  }
}
########### route_table ########### 
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.MainRT_name}"
  }
}
########### route_table_association ########### 
resource "aws_route_table_association" "RTA-pub" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.pub-rt.id
}
############## Security group for Instance
resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id
  # Allow SSH (port 22) using putty to login
  ingress {
    description = "Allow all_traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "From Server VPC to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_all"
  }
}
############## Instance ##########
resource "aws_instance" "public-web-server" {
  # count             = length(var.public_subnet_cidr)
  availability_zone           = "ap-south-1a"
  ami                         = "ami-0522ab6e1ddcc7055"
  instance_type               = "t2.micro"
  key_name                    = "DevOpsKey"
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "${var.vpc_cidr_name}-Public-Server-1"
  }
}