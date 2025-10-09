provider "aws" {
  region = "us-east-1" # change as needed
}

# -----------------------------
# Variable Definition
# -----------------------------
variable "key_name" {
  description = "Name of the existing AWS Key Pair to use for SSH access"
  type        = string
}

# -----------------------------
# 1. VPC
# -----------------------------
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom-vpc"
  }
}

# -----------------------------
# 2. Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom-igw"
  }
}

# -----------------------------
# 3. Public Subnet
# -----------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# -----------------------------
# 4. Route Table
# -----------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "public-rt"
  }
}

# -----------------------------
# 5. Route for Internet Access
# -----------------------------
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# -----------------------------
# 6. Associate Route Table with Subnet
# -----------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# -----------------------------
# 7. Security Group
# -----------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.custom_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# -----------------------------
# 8. EC2 Instance
# -----------------------------
resource "aws_instance" "web" {
  ami                         = "mi-0360c520857e3138f" # Amazon Linux 2 in us-east-1
  instance_type               = "t4.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "terraform-ec2"
  }
}
