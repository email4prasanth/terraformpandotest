# create security group for the web server
resource "aws_security_group" "rds_security_group" {
  name        = "rds security group"
  description = "enable http access on port 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow all inbound traffic"
  }
}

# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name = "database_subnets"
  subnet_ids = [
    for i in range(length(var.public_subnet_cidr)) :
    element(aws_subnet.public_subnet, i).id
  ]
  description = "subnets for database"

  tags = {
    Name = "database_subnets"
  }
}


# create the rds instance postgres
resource "aws_db_instance" "db_instance" {
  engine                  = "mysql"  
  engine_version          = "8.0.35"
  multi_az                = false
  username                = "admin"
  password                = "India123456"
  identifier              = "dkuttimsyql"
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_security_group.id]
  availability_zone       = "ap-south-1a"
  db_name                 = "applicationdb"
  skip_final_snapshot     = true
  publicly_accessible     = true
  deletion_protection     = false
  backup_retention_period = 0 # Disables automated backups
  monitoring_interval     = 0 # Disables enhanced monitoring
  tags = {
    Name = "wiki_js_db"
  }
}

output "db_instance_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}