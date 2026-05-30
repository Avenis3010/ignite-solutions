module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "demo-eks"
  cluster_version = "1.30"

  vpc_id     = var.vpc_id

  subnet_ids = concat(
    var.private_subnets,
    var.public_subnets
  )
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
 

  eks_managed_node_groups = {
    default = {
      instance_types = ["m7i-flex.large"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
    }
  }
}