resource "aws_instance" "name-12" {
  ami           = "ami-0bdd88bd06d16ba03"
  instance_type = "t3.micro"
}
 
variable "type" {
    description = "passing values to instance type"
    default= "t3.micro"
    type = string
  
}