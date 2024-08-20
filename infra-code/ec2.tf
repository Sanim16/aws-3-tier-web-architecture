locals {
  variable1  = "admin"
  variable2  = "your_password" #this is done for simplicity and should not be done in production
  db_address = aws_rds_cluster_instance.cluster_instances[0].endpoint
}

data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "app_tier" {
  ami           = data.aws_ami.amazon_ami.id
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

  user_data = base64encode(templatefile("user-data.sh", {
    db_address     = local.db_address
    admin_user     = local.variable1
    admin_password = local.variable2
  }))
}

resource "aws_instance" "web_tier" {
  ami           = data.aws_ami.amazon_ami.id
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
