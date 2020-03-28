variable "region" {
  default     = "eu-west-1"
  description = "AWS Region"
}

variable "region_az_1" {
  default     = "eu-west-1a"
  description = "AWS Region Az 1"
}

variable "region_az_2" {
  default     = "eu-west-1b"
  description = "AWS Region Az 2"
}

variable "region_az_3" {
  default     = "eu-west-1c"
  description = "AWS Region Az 3"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "VPC CIDR Block"
}

variable "public_subnet_1_cidr" {
  description = "Public Subnet 1"
}

variable "public_subnet_2_cidr" {
  description = "Public Subnet 2"
}

variable "public_subnet_3_cidr" {
  description = "Public Subnet 3"
}

variable "private_subnet_1_cidr" {
  description = "Private Subnet 1"
}

variable "private_subnet_2_cidr" {
  description = "Private Subnet 2"
}

variable "private_subnet_3_cidr" {
  description = "Private Subnet 3"
}

