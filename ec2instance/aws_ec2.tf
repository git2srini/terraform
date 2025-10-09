# ==========================
# main.tf
# ==========================

# 1️⃣ AWS Provider
provider "aws" {
  region = "us-east-1"
}



# 3️⃣ Create EC2 Instance
resource "aws_instance" "srini_ec2" {
  ami           = "ami-08c40ec9ead489470"  # Amazon Linux 2023 AMI (for us-east-1)
  instance_type = "t2.micro"                # Free-tier eligible

  tags = {
    Name = "Terraform-EC2"
  }
}


