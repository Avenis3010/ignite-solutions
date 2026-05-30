resource "aws_ecr_repository" "backend" {
  name = "backend-api"
}

resource "aws_ecr_repository" "frontend" {
  name = "frontend-ui"
}