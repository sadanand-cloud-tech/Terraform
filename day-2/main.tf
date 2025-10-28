resource "aws_vpc" "name" {
    cidr_block = var.aws_vpc
    tags = {
      Name ="one1"
    }
}
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = var.aws_subnet
    tags = {
        Name = "my subnet1"
      
    }
  
}
resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = "t3.micro"
    tags = {
        Name = "ec2-1"
      
    }
  
}