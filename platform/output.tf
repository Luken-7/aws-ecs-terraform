output "vpc_id" {
  value = data.terraform_remote_state.infrastructure.outputs.vpc_id
}

output "vpc_cidr_block" {
  value = data.terraform_remote_state.infrastructure.outputs.vpc_cidr_block
}

output "ecs_alb_listener_arn" {
  value = aws_alb_listener.ecs_alb_listener_http.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.prod-ecs-cluster.name
}

output "ecs_cluster_role_name" {
  value = "${aws_iam_role.ecs_cluster_role.name}"
}

output "ecs_cluster_role_arn" {
  value = "${aws_iam_role.ecs_cluster_role.arn}"
}

output "public_subnet_1_id" {
  value = "${data.terraform_remote_state.infrastructure.outputs.public_subnet_1_id}"
}

output "public_subnet_2_id" {
  value = "${data.terraform_remote_state.infrastructure.outputs.public_subnet_2_id}"
}

output "public_subnet_3_id" {
  value = "${data.terraform_remote_state.infrastructure.outputs.public_subnet_3_id}"
}


output "private_subnet_1_id" {
  value = "${data.terraform_remote_state.infrastructure.outputs.private_subnet_1_id}"
}

output "private_subnet_2_id" {
  value = "${data.terraform_remote_state.infrastructure.outputs.private_subnet_2_id}"
}

output "private_subnet_3_id" {
  value = "${data.terraform_remote_state.infrastructure.outputs.private_subnet_3_id}"
}

output "ecs_public_subnets" {
  value = "${data.terraform_remote_state.infrastructure.outputs.public_subnets}"
}

output "ecs_private_subnets" {
  value = "${data.terraform_remote_state.infrastructure.outputs.private_subnets}"
}

