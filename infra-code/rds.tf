resource "aws_db_subnet_group" "aws_3_tier_subnet_group" {
  name       = "aws_3_tier_subnet_group"
  subnet_ids = [aws_subnet.Private-DB-Subnet-AZ-1.id, aws_subnet.Private-DB-Subnet-AZ-2.id]

  tags = {
    Name = "AWs 3 Tier DB subnet group"
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "database-1"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"
  availability_zones      = ["us-east-1a", "us-east-1b"]
  database_name           = "database1"
  master_username         = "admin"
  master_password         = var.db_password # Note that this may show up in logs, and it will be stored in the state file. 
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.aws_3_tier_subnet_group.name
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.database-sg.id]

  lifecycle {
    ignore_changes = [availability_zones]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = 2
  identifier           = "database-1-${count.index}"
  cluster_identifier   = aws_rds_cluster.default.id
  instance_class       = "db.r5.large"
  engine               = aws_rds_cluster.default.engine
  engine_version       = aws_rds_cluster.default.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.aws_3_tier_subnet_group.name
}

output "rds-url" {
  value = aws_rds_cluster_instance.cluster_instances.*.endpoint
}

output "rds-endpoint" {
  value = aws_rds_cluster_instance.cluster_instances[*].endpoint
}

output "rds-engine" {
  value = aws_rds_cluster_instance.cluster_instances[*].engine_version
}
