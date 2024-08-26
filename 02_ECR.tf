############# ECR Creation ############
resource "aws_ecr_repository" "wiki_js" {
  name                 = "deletewikirepo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "wiki_js"
  }
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.wiki_js.repository_url
  description = "The URL of the ECR repository"
}
############ Push Image to ECR #############
resource "null_resource" "push_docker_image" {
  provisioner "local-exec" {
    command     = <<EOT
    echo "${aws_ecr_repository.wiki_js.repository_url}"
    powershell 'docker login --username AWS -p $(aws ecr get-login-password --region ap-south-1 ) ${aws_ecr_repository.wiki_js.repository_url}'
    # aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.wiki_js.repository_url}
    Start-Sleep -Seconds 10
    docker pull ghcr.io/requarks/wiki:latest
    # docker scout quickview ghcr.io/requarks/wiki:latest
    docker tag ghcr.io/requarks/wiki:latest ${aws_ecr_repository.wiki_js.repository_url}:latest
    Start-Sleep -Seconds 10
    echo "---------Pushing the image to ECR----------"
    docker push ${aws_ecr_repository.wiki_js.repository_url}:latest
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  triggers = {
    always_run   = "${timestamp()}"
    ecr_repo_url = aws_ecr_repository.wiki_js.repository_url
  }
}



