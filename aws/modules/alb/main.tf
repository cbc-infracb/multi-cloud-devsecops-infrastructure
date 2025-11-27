resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.enable_logging ? [1] : []
    content {
      bucket  = var.log_bucket_name
      prefix  = "alb-logs"
      enabled = true
    }
  }

  tags = var.tags
}

resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}