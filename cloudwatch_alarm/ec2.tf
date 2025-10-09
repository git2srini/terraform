resource "aws_instance" "linux1" {
  ami           = "ami-08c40ec9ead489470" # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  subnet_id     = "subnet-051e4b252eab6007c" # ✅ replace with your subnet ID
  vpc_security_group_ids = ["sg-0c69e8a3781d48e8c"] # ✅ replace with your security group ID
  key_name = "srini-keypair"

  tags = {
    Name = "EC2-demo"
  }

}
