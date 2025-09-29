resource "aws_instance" "free_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1 free-tier)
  instance_type = "t2.micro"              # Free-tier eligible
 

  tags = {
    Name = "FreeTier-EC2"
  }
}

# Manage its power state separately
resource "aws_ec2_instance_state" "stop_instance" {
  instance_id = "i-01c978316051df228"
  state       = "stopped"   # can be "running" or "stopped"
}
