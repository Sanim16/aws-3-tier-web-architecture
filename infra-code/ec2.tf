# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

resource "aws_instance" "main" {
  #   ami           = data.aws_ami.ubuntu.id
  ami           = "ami-0195204d5dce06d99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Private-App-Subnet-AZ-1.id

  vpc_security_group_ids = [aws_security_group.private-instance-sg.id]

  associate_public_ip_address = true

  availability_zone = "us-east-1a"
  key_name          = "terraformkey"

  tags = {
    Name = "AppLayer"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_role_profile.name

  depends_on = [aws_internet_gateway.aws_3_tier_architecture_igw]
}

resource "aws_instance" "web_tier" {
  #   ami           = data.aws_ami.ubuntu.id
  ami           = "ami-0195204d5dce06d99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Public-Web-Subnet-AZ-1.id

  vpc_security_group_ids = [aws_security_group.web-tier-sg.id]

  associate_public_ip_address = true

  availability_zone = "us-east-1a"

  tags = {
    Name = "WebLayer"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_role_profile.name

  depends_on = [aws_internet_gateway.aws_3_tier_architecture_igw]
}
