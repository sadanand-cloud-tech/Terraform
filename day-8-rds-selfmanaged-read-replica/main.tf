resource "aws_db_instance" "default" {
  allocated_storage       = 10
  db_name                 = "mydb"
  identifier              = "rds-test"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Sadhi431"
  db_subnet_group_name    = aws_db_subnet_group.sub-grp.id
  parameter_group_name    = "default.mysql8.0"

  # Enable backups and retention
  backup_retention_period  = 7   # Retain backups for 7 days
  backup_window            = "02:00-03:00" # Daily backup window (UTC)

  # Enable monitoring (CloudWatch Enhanced Monitoring)
  monitoring_interval      = 60  # Collect metrics every 60 seconds
  monitoring_role_arn      = aws_iam_role.admin2.arn

  # Enable performance insights
  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7  # Retain insights for 7 days

  # Maintenance window
  maintenance_window = "sun:04:00-sun:05:00"  # Maintenance every Sunday (UTC)

  # Enable deletion protection (to prevent accidental deletion)
  deletion_protection = false

  # Skip final snapshot
  skip_final_snapshot = true
}

# # IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "admin2" {
  name = "rds-monitoring-role-terraform"
assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

#IAM Policy Attachment for RDS Monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.admin2.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


# resource "aws_db_subnet_group" "sub-grp" {
#   name       = "mycutsubnet"
#   subnet_ids = ["subnet-0b176707b172a4b24", "subnet-0e568e5606e63c6ba"]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }




####### with data source ###########
data "aws_subnet" "subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["my-subnet-1"]
  }
}

data "aws_subnet" "subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["my-subnet-2"]
  }
}
resource "aws_db_subnet_group" "sub-grp" {
  name       = "mycutsubnett"
  subnet_ids = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# ------------------------------------
# RDS Read Replica (WORKING CODE)
# ------------------------------------
# resource "aws_db_instance" "rds_read_replica" {
#   identifier           = "rds-test-read-replica"

#   # USE ARN instead of identifier (important)
#   replicate_source_db  = 

#   instance_class       = "db.t3.micro"
#   publicly_accessible  = false

#   # Must match primary instance
#   engine               = "mysql"
#   engine_version       = "8.0"

#   # Subnet group (same as primary)
#   db_subnet_group_name = aws_db_subnet_group.sub-grp.id

#   # Monitoring (optional)
#   monitoring_interval  = 60
#   monitoring_role_arn  = aws_iam_role.admin2.arn

#   # Make sure RDS is created before replica
#   depends_on = [
#     aws_db_instance.default
#   ]
#}


# -----------------------------------
# Read Replica for RDS (Using Existing Primary)
# -----------------------------------

resource "aws_db_instance" "read_replica" {
  identifier          = "rds-test-replica"

  # ✅ ARN must be in quotes
  replicate_source_db = "arn:aws:rds:us-east-1:407291110458:db:rds-test"

  instance_class       = "db.t3.micro"
  publicly_accessible  = false
  parameter_group_name = "default.mysql8.0"

  # ✅ Use subnet group name directly (string)
  db_subnet_group_name = "mycutsubnett"

  # ✅ IAM monitoring role (use existing ARN)
  monitoring_interval = 60
  monitoring_role_arn = "arn:aws:iam::407291110458:role/rds-monitoring-role-terraform"
  deletion_protection  = false
  skip_final_snapshot = true

  tags = {
    Name = "rds-read-replica"
    Role = "ReadReplica"
  }
}
