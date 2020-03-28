terraform {
  backend "s3" {
    key     = "PROD/infrastructure.tfstate"
    bucket  = "terraform-ecs-state"
    region  = "eu-west-1"
  }
}