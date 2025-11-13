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

# -----------------------
# VPC Module
# -----------------------
module "vpc" {
  source        = "./modules/vpc"
  cidr_block    = "10.0.0.0/16"
  subnet_1_cidr = "10.0.1.0/24"
  subnet_2_cidr = "10.0.2.0/24"
  az1           = "us-east-1a"
  az2           = "us-east-1b"
}

# -----------------------
# EC2 Module
# -----------------------
module "ec2" {
    source = "./modules/instance"
    ami_id = "ami-0cae6d6fe6048ca2c"
    instance_type = "t3.micro"
    subnet_1_id = module.vpc.subnet_1_id

  
}

# -----------------------
# RDS Module
# -----------------------
# module "rds" {
#   source         = "./modules/rds"
#   subnet_1_id    = module.vpc.subnet_1_id
#   subnet_2_id    = module.vpc.subnet_2_id
#   instance_class = "db.t3.micro"
#   db_name        = "mydb"
#   db_user        = "admin"
#   db_password    = "sadhi431" # ⚠️ Use SSM or variable in real projects
# }

module "rds" {
  source         = "./modules/rds"
  subnet_1_id    = module.vpc.subnet_1_id
  subnet_2_id    = module.vpc.subnet_2_id
  instance_class = "db.t3.micro"
  db_name        = "mydb"
  db_user        = "admin"
  db_password    = "sadhi431"
}

# -----------------------
# S3 Module
# -----------------------
# module "s3" {
#   source = "./modules/s3"
#   bucket = "sadanandam38"
# }
