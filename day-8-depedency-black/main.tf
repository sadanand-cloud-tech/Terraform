resource "aws_instance" "name-1" { 
    instance_type = "t3.micro"
     ami = "ami-0bdd88bd06d16ba03"
     tags = {
       Name = "dev"
     }
     
  
}

resource "aws_s3_bucket" "name-11" {
    bucket = "sadanan1234567890"
    
  
}