output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_backend_url" {
  value = module.ecr.backend_repo_url
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "cloudfront_url" {
  value = module.cloudfront.cloudfront_domain
}