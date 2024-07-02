resource "aws_security_group" "internet-facing-lb-sg" {
  name        = "internet-facing-lb-sg"
  description = "External load balancer security group"
  vpc_id      = aws_vpc.aws_3_tier_architecture.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "internet-facing-lb-sg-ssh" {
  security_group_id = aws_security_group.internet-facing-lb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "internet-facing-lb-sg-http" {
  security_group_id = aws_security_group.internet-facing-lb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_security_group" "web-tier-sg" {
  name        = "web-tier-sg"
  description = "sg for the web tier"
  vpc_id      = aws_vpc.aws_3_tier_architecture.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "web-tier-sg-internet-lb" {
  security_group_id = aws_security_group.web-tier-sg.id

  referenced_security_group_id = aws_security_group.internet-facing-lb-sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "web-tier-sg-http" {
  security_group_id = aws_security_group.web-tier-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "web-tier-sg-https" {
  security_group_id = aws_security_group.web-tier-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_security_group" "internal-lb-sg" {
  name        = "internal-lb-sg"
  description = "Internal load balancer security group"
  vpc_id      = aws_vpc.aws_3_tier_architecture.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal-lb-sg-web-tier" {
  security_group_id = aws_security_group.internal-lb-sg.id

  referenced_security_group_id = aws_security_group.web-tier-sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_security_group" "private-instance-sg" {
  name        = "private-instance-sg"
  description = "Private App tier security group"
  vpc_id      = aws_vpc.aws_3_tier_architecture.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "private-instance-sg-app-tier" {
  security_group_id = aws_security_group.private-instance-sg.id

  referenced_security_group_id = aws_security_group.internal-lb-sg.id
  from_port                    = 4000
  ip_protocol                  = "tcp"
  to_port                      = 4000
}

resource "aws_vpc_security_group_ingress_rule" "private-instance-sg-app-test" {
  security_group_id = aws_security_group.private-instance-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 4000
  ip_protocol = "tcp"
  to_port     = 4000
}

resource "aws_security_group" "database-sg" {
  name        = "database-sg"
  description = "Database security group"
  vpc_id      = aws_vpc.aws_3_tier_architecture.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "database-sg-aurora" {
  security_group_id = aws_security_group.database-sg.id

  referenced_security_group_id = aws_security_group.private-instance-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}
