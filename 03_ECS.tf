########## ECS Cluster ################
resource "aws_ecs_cluster" "wiki_js_cluster" {
  name = "wiki-js-cluster"
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
