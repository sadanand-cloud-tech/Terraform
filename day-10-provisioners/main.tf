provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# ✅ Key Pair
# -----------------------------
resource "aws_key_pair" "example" {
  key_name   = "projectkey"
  public_key = file("C:/Users/DELL/.ssh/id_ed25519.pub")
}


# -----------------------------
# ✅ VPC
# -----------------------------
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# -----------------------------
# ✅ Subnet
# -----------------------------
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# -----------------------------
# ✅ Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# -----------------------------
# ✅ Route Table
# -----------------------------
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# -----------------------------
# ✅ Route Table Association
# -----------------------------
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

# -----------------------------
# ✅ Security Group
# -----------------------------
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# ✅ EC2 Instance (Ubuntu)
# -----------------------------
resource "aws_instance" "server" {
  ami                         = "ami-0261755bbcb8c4a84" # Ubuntu AMI
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.example.key_name
  subnet_id                   = aws_subnet.sub1.id
  vpc_security_group_ids      = [aws_security_group.webSg.id]
  associate_public_ip_address = true

  tags = {
    Name = "UbuntuServer"
  }
}

# -----------------------------
# ✅ Null Resource (Provisioner)
# Forces provisioner to run every apply
# -----------------------------
resource "null_resource" "run_script" {
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.server.public_ip
      user        = "ubuntu"
      private_key = file("C:/Users/DELL/.ssh/id_ed25519") # ✅ PATH TO PRIVATE KEY
    }

    inline = [
      "echo 'hello from awsdevopsmulticloud-by-veera' >> /home/ubuntu/file200"
    ]
  }

  triggers = {
    always_run = timestamp()  # ✅ Forces re-run every time
  }
}
