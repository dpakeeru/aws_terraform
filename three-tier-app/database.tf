#Creating a subnet group for private subnets to connect to database
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name = "aurora-subnet-group"
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  tags = {
    Name = "aurora-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "aurora-cluster"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  master_username = "admin"
  master_password = "Pokemon123!"
  database_name = "mydatabase"
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  storage_encrypted = true
  vpc_security_group_ids = [ aws_security_group.db_tier_lb_sg.id ]
  deletion_protection = false
  skip_final_snapshot = false
  final_snapshot_identifier = "aurora-cluster-snapshot"

  tags = {
    Name = "aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instances" {
  count = 2
  identifier = "aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class = "db.r5.large"
  engine = aws_rds_cluster.aurora_cluster.engine
  engine_version = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  apply_immediately = true

  tags = {
    Name = "aurora-instance-${count.index + 1}"
  }
}