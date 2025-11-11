terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Generate random password for RDS
resource "random_password" "rds_password" {
  length  = 12
  special = true
}

# Security group for RDS - allow EC2 access
resource "aws_security_group" "rds_sg" {
  name = "rds-mysql-sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change to EC2 SG later for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # RDS MySQL instance
resource "aws_db_instance" "mysql_rds" {
  identifier           = "my-mysql-db"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = random_password.rds_password.result
  allocated_storage    = 20
  db_name              = "mydb"                 # ✅ Fixed
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}


# EC2 for executing SQL
resource "aws_instance" "sql_runner" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = "my-key"                # use an existing SSH key
  associate_public_ip_address = true

  tags = {
    Name = "SQL-Runner"
  }
}

# Execute init.sql remotely from EC2 to RDS
resource "null_resource" "remote_sql_exec" {
  depends_on = [
    aws_db_instance.mysql_rds,
    aws_instance.sql_runner
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.sql_runner.public_ip
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y mariadb",  # install MySQL client
      "mysql -h ${aws_db_instance.mysql_rds.address} -u admin -p\"${random_password.rds_password.result}\" < /tmp/init.sql"
    ]
  }

  triggers = {
    always_run = timestamp()
  }
}
