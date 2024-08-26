### Develop a Terraform script that performs the following tasks:
    - Create a VPC with both private and public subnets.
    - Deploy the Wiki.js application from an online codebase - https://js.wiki/.
    - Setup ECR private repo - Push image to that repo.
    - Set up an ECS cluster.
    - Create an IAM role for ECS that can download files from a specified S3 bucket.
    - Establish an RDS Postgres database accessible only from a specific ECS instance.
    - Set up an ALB and target group to host the Wiki.js website.
