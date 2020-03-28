# aws-ecs-terraform
Terraform configuration for AWS - ECS
This is a terraform template for build with IaaC a AWS environment with ALB, Target Group, Route 53, ECS (Fargate), AutoScaling, etc.

Terraform Version:
Terraform v0.12.24


AWS CLI Version:
aws-cli/1.14.44 Python/3.6.9 Linux/4.15.0-1057-aws botocore/1.8.48


To Build the environment:

1. Go to "infrastructure" directory and run :
    a. terraform init
	b. terraform apply

2. Go to "platform" directory and run :
	a. terraform init
	b. terraform apply (the command asks for the public domain)

3. Go to "application/infrastructure" directory and run:
	a. ./deploy.sh dockerize XXXXXXXXX (where XXXXXXXXX is AWS Account number)
	b. ./deploy.sh deploy XXXXXXXXX
