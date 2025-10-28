resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name ="one"
    }
}
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "my subnet"
      
    }
  
}
resource "aws_instance" "name" {
    ami ="ami-07860a2d7eb515d9a"
    instance_type = "t3.micro"
    tags = {
        Name = "ec2-1"
      
    }
  
}