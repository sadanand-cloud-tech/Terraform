# 1️⃣ Create VPC
resource "aws_vpc" "cust_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cust-vpc"
  }
}

# 2️⃣ Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cust_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# 3️⃣ Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.cust_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-1c"
  tags = {
    Name = "private-subnet"
  }
}

# 4️⃣ Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cust_vpc.id
  tags = {
    Name = "cust-igw"
  }
}

# 5️⃣ Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 6️⃣ Elastic IP (for NAT Gateway)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "cust-nat-eip"
  }
}

# 7️⃣ NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "cust-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# 8️⃣ Private Route Table (NAT access)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# 9️⃣ Security Group
resource "aws_security_group" "cust_sg" {
  name        = "cust-sg"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = aws_vpc.cust_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cust-sg"
  }
}

# 🔟 Public EC2 Instance (no key pair)
resource "aws_instance" "public_ec2" {
  ami                         = "ami-03978d951b279ec0b" # Amazon Linux 2
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.cust_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "public-ec2"
  }
}

# 11️⃣ Private EC2 Instance (no key pair)
resource "aws_instance" "private_ec2" {
  ami                    = "ami-03978d951b279ec0b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.cust_sg.id]

  tags = {
    Name = "private-ec2"
  }
}
resource "aws_s3_bucket" "name" {
    bucket = "asdfghjkertyuiopbm"

}

##terraform apply -target=aws_s3_bucket.name
#terraform destroy -target=aws_instance.public_ec2
