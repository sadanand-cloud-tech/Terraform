provider "aws" {
  region = "us-east-1"
}

# ✅ Import existing SSH public key from your system
resource "aws_key_pair" "example" {
  key_name   = "task"
  public_key = file("C:/Users/DELL/.ssh/id_ed25519.pub")   # <-- UPDATE this path
}

resource "aws_instance" "server" {
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "Terraform-EC2"
  }
}
