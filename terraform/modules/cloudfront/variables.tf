variable "s3_bucket_domain" {}
variable "origin_domain" {
  type        = string
  description = "S3 bucket or ALB origin domain for CloudFront"
}