provider "aws" {
  region = var.region
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    region = var.region
    bucket = var.remote-state-bucket
    key = var.remote-state-key
  }
}

resource "aws_ecs_cluster" "prod-ecs-cluster" {
  name = "Prod-ECS-Cluster"
}

resource "aws_alb" "ecs-cluster-alb" {
  name            = "${var.ecs-cluster-name}-ALB"
  internal        = false
  security_groups = [aws_security_group.ecs-alb-sec-group.id]
  subnets         = [data.terraform_remote_state.infrastructure.outputs.public_subnet_1_id,
    data.terraform_remote_state.infrastructure.outputs.public_subnet_2_id,
    data.terraform_remote_state.infrastructure.outputs.public_subnet_3_id]
  tags = {
    Name = "${var.ecs-cluster-name}-ALB"
  }
}

resource "aws_alb_listener" "ecs_alb_listener_http" {
  load_balancer_arn = aws_alb.ecs-cluster-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
  }
  depends_on = [aws_alb_target_group.ecs_default_target_group]
}

resource "aws_alb_target_group" "ecs_default_target_group" {
  name      = "${var.ecs-cluster-name}-TG"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = data.terraform_remote_state.infrastructure.outputs.vpc_id
  tags = {
    Name = "${var.ecs-cluster-name}-TG"
  }
}

resource "aws_iam_role" "ecs_cluster_role" {
  name                = "${var.ecs-cluster-name}-IAM-Role"
  assume_role_policy  = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
    },
    "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name                = "${var.ecs-cluster-name}-IAM-Policy"
  role                =  aws_iam_role.ecs_cluster_role.id
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "cloudwatch:*",
        "s3:*",
        "rds:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_route53_zone" "selected" {
  name         = var.public_domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.record_cname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.ecs-cluster-alb.dns_name]
}

