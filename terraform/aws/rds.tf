resource "aws_db_subnet_group" "default" {
  name       = "mce-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "postgres" {
  identifier = "mce-postgres-${var.project_suffix}"
  engine = "postgres"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  vpc_security_group_ids = []
  db_subnet_group_name = aws_db_subnet_group.default.name
}
