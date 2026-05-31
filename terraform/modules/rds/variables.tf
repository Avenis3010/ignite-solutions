variable "subnet_ids" {
  type = list(string)
}

variable "db_password" {
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}