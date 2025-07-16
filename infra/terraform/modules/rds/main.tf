resource "aws_db_instance" "this" {
  identifier          = var.db_name
  username            = var.username
  password            = var.password
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  skip_final_snapshot = true
  publicly_accessible = true
}
