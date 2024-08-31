data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.cluster_name

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    "${var.service_name}" = {
      cpu    = 512
      memory = 1024

      container_definitions = {
        "${var.container_name}" = {
          essential = true 
          image     = var.image_url
          port_mappings = [
            {
              name          = var.container_name
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
          readonly_root_filesystem = false
        }
      }
      assign_public_ip = true
      deployment_minimum_healthy_percent = 100
      subnet_ids = flatten(data.aws_subnets.public.ids)
      security_group_ids  = [aws_security_group.allow_sg.id]
    }
  }
}

resource "aws_security_group" "allow_sg" {
  name        = "ben_allow_tls"
  description = "Allow traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_sg"
  }
}

resource "aws_ecr_repository" "example" {
  name                 = "ben-ecr"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "ben-ecr"
    Environment = "dev"
  }
}

output "ecs_cluster_name" {
  description = "ben-ecs"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ben-service"
  value       = var.service_name
}

output "ecr_repository_url" {
  description = "this is a image url"
  value       = aws_ecr_repository.example.repository_url
}