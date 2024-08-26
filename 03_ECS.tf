########## ECS Cluster ################
resource "aws_ecs_cluster" "wiki_js_cluster" {
  name = "wiki-js-cluster"
}

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
############ Launch EC2 Instances in the ECS Cluster ##########
resource "aws_launch_configuration" "ecs_instance" {
  name            = "ecs-instance-lc"
  image_id        = "ami-02b49a24cfb95941c" # Update this with a suitable Amazon ECS-optimized AMI
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ecs_sg.id]
  user_data       = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.wiki_js_cluster.name} >> /etc/ecs/ecs.config
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_instance_asg" {
  launch_configuration = aws_launch_configuration.ecs_instance.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet[0].id]

  tag {
    key                 = "Name"
    value               = "ECS Instance"
    propagate_at_launch = true
  }
}
###### Task Definition #########
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task-family"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "${aws_ecr_repository.wiki_js.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}
############## Create the ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.wiki_js_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = aws_lb_target_group.wiki_js_tg.arn
    container_name   = "my-container"
    container_port   = 80
  }
}


####### IAM Role ###########
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ecs_task_execution_role"
  }
}

# IAM Policy for ECS Task Execution Role
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ecsTaskExecutionPolicy"
  description = "Policy for ECS Task Execution Role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
# Attach IAM Policy to ECS Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

### Create S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "pandotestbucket" # Replace with a globally unique bucket name
  tags = {
    Name        = "pando_bucket"
    Environment = "Dev"
  }
}
# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
# S3 Access Policy for ECS Tasks
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow ECS tasks to access a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::pandotestbucket",
          "arn:aws:s3:::pandotestbucket/*"
        ]
      }
    ]
  })
}
