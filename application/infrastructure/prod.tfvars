remote-state-key = "PROD/platform.tfstate"
remote-state-bucket = "terraform-ecs-state"

ecs_service_name = "python-app"
docker_container_port = 80
desired_task_number = "2"
python_profile = "default"
memory_task = 1024
cpu_task = 256

