provider "aws" {
  region = var.region
}

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    region  = var.region
    bucket  = var.remote-state-bucket
    key     = var.remote-state-key
  }
}

data "template_file" "ecs_task_definition_template" {
  template = "${file("task.json")}"
  vars = {
        task_definition_name  = var.ecs_service_name
        ecs_service_name      = var.ecs_service_name
        docker_image_url      = var.docker_image_url
        memory_task           = var.memory_task
        docker_container_port = var.docker_container_port
        python_profile        = var.python_profile
        region                = var.region
}
}

resource "aws_ecs_task_definition" "python-simple-app-task-definition" {
  container_definitions     = data.template_file.ecs_task_definition_template.rendered
  family                    = var.ecs_service_name
  memory                    = var.memory_task
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = var.cpu_task
  execution_role_arn        = aws_iam_role.fargate_role.arn
  task_role_arn             = aws_iam_role.fargate_role.arn
}

resource "aws_iam_role" "fargate_role" {
  name                = "${var.ecs_service_name}-IAM-Role"
  assume_role_policy  = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    },
    "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}

resource "aws_iam_role_policy" "fargate_policy" {
  name                = "${var.ecs_service_name}-IAM-Policy"
  role                =  aws_iam_role.fargate_role.id
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "logs:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_alb_target_group" "ecs_app_target_group" {
  name                  = "${var.ecs_service_name}-TG"
  port                  = var.docker_container_port
  protocol              = "HTTP"
  vpc_id                = data.terraform_remote_state.platform.outputs.vpc_id
  target_type           = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 30
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }

}

resource "aws_ecs_service" "ecs_service" {
  name              = var.ecs_service_name
  task_definition   = var.ecs_service_name
  desired_count     = var.desired_task_number
  cluster           = data.terraform_remote_state.platform.outputs.ecs_cluster_name
  launch_type       = "FARGATE"

  network_configuration  {
    subnets             = [data.terraform_remote_state.platform.outputs.public_subnet_1_id,
      data.terraform_remote_state.platform.outputs.public_subnet_2_id,
      data.terraform_remote_state.platform.outputs.public_subnet_3_id]
    security_groups     = [aws_security_group.app-python-sec-group.id]
    assign_public_ip    = true
  }

  load_balancer {
    container_name = var.ecs_service_name
    container_port = var.docker_container_port
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }
  depends_on = [ aws_alb_target_group.ecs_app_target_group]
}

resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn  = data.terraform_remote_state.platform.outputs.ecs_alb_listener_arn

  action {
    type              = "forward"
    target_group_arn  = aws_alb_target_group.ecs_app_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
resource "aws_cloudwatch_log_group" "pythonapp" {
  name = "${var.ecs_service_name}-LogGroup"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${var.ecs_service_name}-CPU-Utilization-High-${var.ecs_as_cpu_high_threshold_per}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_high_threshold_per

  dimensions = {
    ClusterName = data.terraform_remote_state.platform.outputs.ecs_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "${var.ecs_service_name}-CPU-Utilization-Low-${var.ecs_as_cpu_low_threshold_per}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_low_threshold_per

  dimensions = {
    ClusterName = data.terraform_remote_state.platform.outputs.ecs_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_down.arn]
}

resource "aws_appautoscaling_policy" "app_up" {
  name               = "app-scale-up"
  service_namespace  = aws_appautoscaling_target.app_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "app_down" {
  name               = "app-scale-down"
  service_namespace  = aws_appautoscaling_target.app_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_target" "app_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${data.terraform_remote_state.platform.outputs.ecs_cluster_name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}