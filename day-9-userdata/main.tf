resource "aws_instance" "name" { 
    instance_type = "t3.micro"
     ami = "ami-0bdd88bd06d16ba03"
     user_data = file("test.sh")  # calling test.sh from current directory by using file fucntion 
     tags = {
       Name = "sad"
     }


  
}