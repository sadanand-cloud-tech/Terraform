#########################################
# Key Pair Resource
#########################################
resource "aws_key_pair" "terraform_keypair" {
  key_name   = "terraforms-keypair"
  public_key = file("C:/Users/DELL/.ssh/id_ed25519.pub") # path to your public SSH key
}

#########################################
# Frontend Resources
#########################################
data "aws_ami" "frontend" {
  most_recent = true
  owners      = ["amazon"] # use official Amazon AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Amazon Linux 2 pattern
  }
}

# Launch Template Resource
resource "aws_launch_template" "frontend" {
  name                   = "frontend-terraform-v22"
  description             = "frontend-terraform"
  image_id                = var.ami
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [aws_security_group.frontend-server-sg.id]
  key_name                = aws_key_pair.terraform_keypair.key_name
  #default_version         = 1
  update_default_version  = true
  #user_data              = filebase64("${path.module}/frontend-lt.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "frontend-terraform"
    }
  }
}

###################################################################################
# Backend Resources
###################################################################################
data "aws_ami" "backend" {
  most_recent = true
  owners      = ["amazon"] # use official Amazon AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Amazon Linux 2 pattern
  }
}

# Launch Template Resource
resource "aws_launch_template" "backend" {
  name                   = "backend-terraform-v21"
  description             = "backend-terraform"
  image_id                = var.ami
  instance_type           = "t3.micro"
  vpc_security_group_ids  = [aws_security_group.backend-server-sg.id]
  key_name                = aws_key_pair.terraform_keypair.key_name
  #default_version         = 1
  update_default_version  = true
  #user_data              = filebase64("${path.module}/backend-lt.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "backend-terraform"
    }
  }
}