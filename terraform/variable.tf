variable "vpc_name" {
  description = "The name of the VPC to use"
  default     = "Default VPC"
}

variable "cluster_name" {
  description = "ben-cluster"
  default     = "ben-ecs-tf"
}

variable "service_name" {
  description = "ben-services"
  default     = "ben-services"
}

variable "container_name" {
  description = "ben-ecs"
  default     = "ecs-sample"
}

variable "image_url" {
  description = "this is a image url"
  default     = "public.ecr.aws/u2q1a2y8/ben/simple-node-app:2"
}