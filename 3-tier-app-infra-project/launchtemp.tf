###############################################
#  FRONTEND LAUNCH TEMPLATE
###############################################
resource "aws_launch_template" "frontend" {
  name        = "frontend-terraform"
  description = "Launch template for Frontend"

  image_id      = "ami-0cae6d6fe6048ca2c"   # <-- Replace with your AMI ID
  instance_type = "t3.micro"
  key_name      = "mlops"              # <-- Replace with your key pair name

  # Optional startup script
  # user_data = filebase64("${path.module}/frontend-lt.sh")

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "frontend-terraform"
      Role = "frontend"
    }
  }
}


###############################################
#  BACKEND LAUNCH TEMPLATE
###############################################
resource "aws_launch_template" "backend" {
  name        = "backend-terraform"
  description = "Launch template for Backend"

  image_id      = "ami-0cae6d6fe6048ca2c"   # <-- Replace with your AMI ID
  instance_type = "t3.micro"
  key_name      = "mlops"              # <-- Replace with your key pair name

  # Optional startup script
  # user_data = filebase64("${path.module}/backend-lt.sh")

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "backend-terraform"
      Role = "backend"
    }
  }
}
