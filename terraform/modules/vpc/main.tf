module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs = ["ap-south-1a", "ap-south-1b"]


  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
  private_subnets = ["10.0.21.0/24", "10.0.22.0/24"]



  enable_nat_gateway = true
  single_nat_gateway = true

  map_public_ip_on_launch = true
}
