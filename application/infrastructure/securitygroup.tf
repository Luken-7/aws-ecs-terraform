resource "aws_security_group" "app-python-sec-group" {
  name            = "${var.ecs_service_name}-SG"
  description     = "Security Group to Python App"
  vpc_id          = data.terraform_remote_state.platform.outputs.vpc_id

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = [data.terraform_remote_state.platform.outputs.vpc_cidr_block]
  }

  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = [var.internet_cidr_blocks]
  }

}