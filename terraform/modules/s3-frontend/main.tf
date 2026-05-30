resource "aws_s3_bucket" "frontend" {
  bucket = "central-platform-frontend-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}