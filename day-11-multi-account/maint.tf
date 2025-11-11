resource "aws_instance" "name" {
  ami="ami-07860a2d7eb515d9a" 
  instance_type = "t3.micro"

}

resource "aws_s3_bucket" "name" {
    bucket = "sadanand57"
    provider = aws.oregon
  
}