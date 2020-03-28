variable "region" {
  default     = "eu-west-1"
  description = "AWS Region"
}

variable "remote-state-bucket" {}
variable "remote-state-key" {}

variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "memory_task" {}
variable "cpu_task" {}
variable "docker_container_port" {}
variable "python_profile" {}

variable "internet_cidr_blocks" {
  default = "0.0.0.0/0"
}

variable "desired_task_number" {}

variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
}


variable "ecs_as_cpu_high_threshold_per" {
  default = "80"
}

variable "ecs_autoscale_min_instances" {
  default = "2"
}

variable "ecs_autoscale_max_instances" {
  default = "10"
}
