resource "aws_lb" "wiki_js_alb" {
  name               = "wiki-js-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    for i in range(length(var.private_subnet_cidr)) : 
    element(aws_subnet.public_subnet, i).id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "wiki_js_alb"
  }
}

resource "aws_lb_target_group" "wiki_js_tg" {
  name     = "wiki-js-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id
}

resource "aws_lb_listener" "wiki_js_listener" {
  load_balancer_arn = aws_lb.wiki_js_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wiki_js_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_sg"
  }
}
