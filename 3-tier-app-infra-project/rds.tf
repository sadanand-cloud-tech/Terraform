# ----------------------------
# DB Subnet Group
# ----------------------------
resource "aws_db_subnet_group" "sub_grp" {
  name       = "main-db-subnet-group"
  subnet_ids = [
    aws_subnet.prvt7.id,
    aws_subnet.prvt8.id
  ]

  tags = {
    Name = "My DB subnet group"
  }
}

# ----------------------------
# RDS Instance (Free Tier)
# ----------------------------
resource "aws_db_instance" "rds" {
  identifier              = "book-rds"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"   # free tier
  db_name                 = "mydb"
  username                = var.rds_username
  password                = var.rds_password

  multi_az                = false           # ⭐ must be false in free tier
  backup_retention_period = 1               # ⭐ free tier max
  skip_final_snapshot     = true
  publicly_accessible     = false

  db_subnet_group_name    = aws_db_subnet_group.sub_grp.name
  vpc_security_group_ids  = [aws_security_group.book_rds_sg.id]

  tags = {
    DB_identifier = "book-rds"
  }
}
