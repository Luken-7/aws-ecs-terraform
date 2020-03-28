terraform {
  backend "s3" {
    key     = "PROD/app.tfstate"
    bucket  = "terraform-ecs-state"
    region  = "eu-west-1"
  }
}