terraform {
  backend "s3" {
    key="PROD/platform.tfstate"
    bucket="terraform-ecs-state"
    region="eu-west-1"

  }
}