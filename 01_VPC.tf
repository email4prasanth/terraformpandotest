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
resource "aws_vpc" "default" {
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
  vpc_id            = aws_vpc.default.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_cidr_name}-public-subnet-${count.index + 1}"
  }
}
########### internet_gateway ########### 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.IGW_name}"
  }
}
########### route_table ########### 
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.default.id

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
########## Private Subnet,Private EIP, NATGW, RT, RTAssociation ############
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.default.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_cidr_name}-private-subnet-${count.index + 1}"
  }
}
########## Elastiv IP ########## 
resource "aws_eip" "nat-eip" {
  tags = {
    Name = "natgw-eip"
  }
}
########## NAT Gateway ########## 
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.private_subnet.0.id #Connected to first private gw
  tags = {
    Name = "NATgw"
  }
  depends_on = [aws_internet_gateway.gw]
}
##########  Private Routing Table ########## 
resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
    Name = "PvtRT_name"
  }
}
##########  RT Association ########## 
resource "aws_route_table_association" "RTA-pvt" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.pvt-rt.id
}
