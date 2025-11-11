provider "aws" {
  region = "us-east-1"
}

# ---------------------------
# 0. Import SSH key into AWS
# ---------------------------
resource "aws_key_pair" "project_key" {
  key_name   = "projectkey"
  public_key = file("c:/Users/DELL/.ssh/id_ed25519.pub")   # <-- PUBLIC KEY (.pub)
}

# ---------------------------
# Security Group for RDS
# ---------------------------
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access only from EC2"

  ingress {
    description = "Allow MySQL from EC2"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# Security Group for EC2
# ---------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH inbound"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# 1. Create RDS MySQL
# ---------------------------
resource "aws_db_instance" "mysql_rds" {
  identifier              = "my-mysql-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Password123!"
  db_name                 = "dev"
  allocated_storage       = 20
  skip_final_snapshot     = true
  publicly_accessible     = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# ---------------------------
# 2. Create EC2
# ---------------------------
resource "aws_instance" "sql_runner" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.project_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "SQL Runner Instance"
  }
}

# ---------------------------
# 3. Execute SQL script from EC2
# ---------------------------
resource "null_resource" "remote_sql_exec" {
  depends_on = [
    aws_db_instance.mysql_rds,
    aws_instance.sql_runner
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("c:/Users/DELL/.ssh/id_ed25519")  # <-- PRIVATE KEY (NO .pub)
    host        = aws_instance.sql_runner.public_ip
  }

  # Upload init.sql to EC2
  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

  # Install MySQL client and execute SQL script
  provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo yum install mariadb -y",
    "mysql -h ${aws_db_instance.mysql_rds.address} -u admin -pPassword123! dev < /tmp/init.sql"
  ]
}

}

# ---------------------------
# Output
# ---------------------------
output "rds_endpoint" {
  value = aws_db_instance.mysql_rds.address
}

output "ec2_public_ip" {
  value = aws_instance.sql_runner.public_ip
}
