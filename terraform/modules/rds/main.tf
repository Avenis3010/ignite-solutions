resource "aws_db_subnet_group" "this" {
  name       = "db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "mysql" {
  identifier = "platform-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  username = "admin"
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.this.name

  skip_final_snapshot = true
  publicly_accessible = false
}