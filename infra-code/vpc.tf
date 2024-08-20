# Create a VPC
resource "aws_vpc" "aws_3_tier_architecture" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "aws_3_tier_architecture_vpc"
  }
}

resource "aws_vpc" "aws_3_tier_architectures" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "aws_3_tier_architecture_vpc"
  }
}

resource "aws_subnet" "Public-Web-Subnet-AZ-1" {
  vpc_id            = aws_vpc.aws_3_tier_architecture.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "web_tier_subnet"
  }
}

resource "aws_subnet" "Private-App-Subnet-AZ-1" {
  vpc_id            = aws_vpc.aws_3_tier_architecture.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "app_tier_subnet"
  }
}

resource "aws_subnet" "Private-DB-Subnet-AZ-1" {
  vpc_id            = aws_vpc.aws_3_tier_architecture.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "db_tier_subnet"
  }
}

resource "aws_subnet" "Public-Web-Subnet-AZ-2" {
  vpc_id            = aws_vpc.aws_3_tier_architecture.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "web_tier_subnet"
  }
}

resource "aws_subnet" "Private-App-Subnet-AZ-2" {
  vpc_id            = aws_vpc.aws_3_tier_architecture.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "app_tier_subnet"
  }
}

resource "aws_subnet" "Private-DB-Subnet-AZ-2" {
  vpc_id            = aws_vpc.aws_3_tier_architecture.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db_tier_subnet"
  }
}

resource "aws_internet_gateway" "aws_3_tier_architecture_igw" {
  vpc_id = aws_vpc.aws_3_tier_architecture.id

  tags = {
    Name = "aws_3_tier_architecture_igw"
  }
}

resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.az1_eip.id
  subnet_id     = aws_subnet.Public-Web-Subnet-AZ-1.id

  tags = {
    Name = "nat_gw_az1"
  }

  depends_on = [aws_internet_gateway.aws_3_tier_architecture_igw]
}

resource "aws_eip" "az1_eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.aws_3_tier_architecture_igw]
}

resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.az2_eip.id
  subnet_id     = aws_subnet.Public-Web-Subnet-AZ-2.id

  tags = {
    Name = "nat_gw_az2"
  }

  depends_on = [aws_internet_gateway.aws_3_tier_architecture_igw]
}

resource "aws_eip" "az2_eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.aws_3_tier_architecture_igw]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.aws_3_tier_architecture.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_3_tier_architecture_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_route_table1" {
  subnet_id      = aws_subnet.Public-Web-Subnet-AZ-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table2" {
  subnet_id      = aws_subnet.Public-Web-Subnet-AZ-2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table_az1" {
  vpc_id = aws_vpc.aws_3_tier_architecture.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az1.id
  }

  tags = {
    Name = "private_route_table_az1"
  }
}

resource "aws_route_table_association" "private_route_table1" {
  subnet_id      = aws_subnet.Private-App-Subnet-AZ-1.id
  route_table_id = aws_route_table.private_route_table_az1.id
}

resource "aws_route_table" "private_route_table_az2" {
  vpc_id = aws_vpc.aws_3_tier_architecture.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az2.id
  }

  tags = {
    Name = "private_route_table_az2"
  }
}

resource "aws_route_table_association" "private_route_table2" {
  subnet_id      = aws_subnet.Private-App-Subnet-AZ-2.id
  route_table_id = aws_route_table.private_route_table_az2.id
}
