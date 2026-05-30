module "vpc" {
  source = "../../modules/vpc"
  vpc_cidr = var.vpc_cidr
  aws_region   = var.aws_region
  project_name = var.project_name
}

module "eks" {
  source = "../../modules/eks"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

module "ecr" {
  source = "../../modules/ecr"
}

module "rds" {
  source      = "../../modules/rds"
  subnet_ids  = module.vpc.private_subnets
  db_password = var.db_password
}

module "s3" {
  source = "../../modules/s3"
}

module "cloudfront" {
  source = "../../modules/cloudfront"
  s3_bucket_domain = module.s3.bucket_domain_name
  origin_domain = var.origin_domain
}
