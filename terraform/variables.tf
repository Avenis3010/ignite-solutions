variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "central-platform"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_password" {
  sensitive = true
}