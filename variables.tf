variable "aws_region" {}
variable "Key_name" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "vpc_cidr_name" {}
variable "public_subnet1_cidr_name" {}
variable "private_subnet1_cidr_name" {}
variable "IGW_name" {}
variable "MainRT_name" {}
variable "azs" {}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}
