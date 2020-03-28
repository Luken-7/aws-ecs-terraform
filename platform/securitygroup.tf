resource "aws_security_group" "ecs-alb-sec-group" {
  name            = "${var.ecs-cluster-name}-ALB-SG"
  description     = "Security Group to ALB"
  vpc_id          = data.terraform_remote_state.infrastructure.outputs.vpc_id

  ingress {
    from_port = 0
    protocol = "TCP"
    to_port = 443
    cidr_blocks = [var.internet_cidr_blocks]
  }

  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = [var.internet_cidr_blocks]
  }

}