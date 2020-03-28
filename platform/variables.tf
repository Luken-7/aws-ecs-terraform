variable "region"{
  default = "eu-west-1"
}

variable "remote-state-bucket" {}
variable "remote-state-key" {}

variable "ecs-cluster-name" {}

variable "internet_cidr_blocks" {}

variable "public_domain_name" {
  type = string
  description = "Name of existing public domain"
}

variable "record_cname" {
  type = string
  description = "Record CNAME associated to the main domain"
}
