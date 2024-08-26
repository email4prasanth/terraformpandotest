# Security group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Allow outbound traffic from ECS to RDS"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
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
    Name = "ecs-sg"
  }
}

# Security group for RDS data base
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow ECS instances to access RDS"
  vpc_id      = aws_vpc.default.id

  ingress {
    description     = "rds postgress access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = [
    for i in range(length(var.private_subnet_cidr)) : 
    element(aws_subnet.private_subnet, i).id
  ]

  tags = {
    Name = "RDS Subnet Group"
  }
}

# create the rds instance
resource "aws_db_instance" "wiki_js_db" {
  engine                 = "postgres"
  engine_version         = "15.4"
  multi_az               = false
  identifier             = "dev-rds-instance"
  username               = "postgres"
  password               = "Prasanth09"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  storage_type           = "gp2"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  # parameter_group_name   = aws_db_parameter_group.education.name
  db_name             = "wikidb"
  skip_final_snapshot = true
  publicly_accessible = true
  tags = {
    Name = "wiki_js_db"
  }
}
