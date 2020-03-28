#!/bin/bash
SERVICE_NAME="pythonapp"
SERVICE_TAG="v1"
AWS_ACCOUNT="$2"
ECR_REPO_URL="${AWS_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com/${SERVICE_NAME}"

if [ "$1" = "dockerize" ] && [ "$2" != "" ] ; then
  echo "Starting Dockerizing the PythonApp..."
  cd ../PythonApp
  $(aws ecr get-login --no-include-email --region eu-west-1)
  aws ecr create-repository --repository-name ${SERVICE_NAME} || true
  docker build -t ${SERVICE_NAME}:${SERVICE_TAG} .
  docker tag ${SERVICE_NAME}:${SERVICE_TAG} ${ECR_REPO_URL}:${SERVICE_TAG}
  docker push ${ECR_REPO_URL}:${SERVICE_TAG}

elif [ "$1" = "plan" ] && [ "$2" != "" ]; then
 terraform init
 terraform plan -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}"

elif [ "$1" = "deploy" ] && [ "$2" != "" ]; then
 terraform init
 terraform taint -allow-missing aws_ecs_task_definition.python-simple-app-task-definition
 terraform apply -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
 aws ecs update-service --cluster Prod-ECS-Cluster --service python-app --task-definition python-app
elif [ "$1" = "destroy" ] && [ "$2" != "" ]; then
 terraform init
 terraform destroy -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
fi
