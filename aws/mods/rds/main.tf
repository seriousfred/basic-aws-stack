# rds postgres module

# getting cidr blocks
data "aws_subnet" "allow" {
  for_each = toset(var.allowed_subnets)
  id       = each.value
}


# security group
resource "aws_security_group" "db_sg" {

  name        = "${var.prefix}-postgres-sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.database_port
    to_port     = var.database_port
    cidr_blocks = [for s in data.aws_subnet.allow : s.cidr_block]
  }

  egress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [for s in data.aws_subnet.allow : s.cidr_block]
  }

  tags = {
    Name = "${var.prefix}-postgres-sg"
  }

}

# subnet group
resource "aws_db_subnet_group" "db_subnet_group" {

  name       = "${var.prefix}-postgres-subnet-group"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.prefix}-postgres-subnet-group"
  }
}

# db parameter group
# @TODO enable SSL
resource "aws_db_parameter_group" "db_parameter_group" {

  name        = "${var.prefix}-postgres-parameter-group"
  family     = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "${var.prefix}-postgres-parameter-group"
  }
}

# secret
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
  min_special      = 1
  min_lower        = 1
  min_upper        = 4
  min_numeric      = 2
}

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${var.prefix}-postgres-credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    DB_USERNAME = var.database_username,
    DB_PASSWORD = random_password.db_password.result
  })
}

# rds instance
resource "aws_db_instance" "postgres" {
  identifier                = "${var.prefix}-postgres"
  instance_class            = var.instance_class
  engine                    = "postgres"
  engine_version            = "17.4"
  name                      = var.database_name
  port                      = var.database_port
  username                  = var.database_username
  password                  = random_password.db_password.result
  storage_type              = "gp2"
  allocated_storage         = var.database_storage
  multi_az                  = var.multi_az
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name      = aws_db_parameter_group.db_parameter_group.name
  publicly_accessible       = false
  vpc_security_group_ids    = [aws_security_group.db_sg.id]
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  copy_tags_to_snapshot       = true
  backup_retention_period     = var.backup_retention_period
  deletion_protection         = false
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.prefix}-postgres-final-snapshot"
#   # TODO
#   performance_insights_enabled           = 
#   performance_insights_retention_period  = 31
#   preferred_backup_window     = 
#   maintenance_window          = 
#   storage_encrypted           = 
#   kms_key_id                  = 
}

resource "aws_ssm_parameter" "postgres_dbname" {
  name  = "/${var.prefix}/postgres/DB_NAME"
  type  = "String"
  value = aws_db_instance.postgres.name
}

resource "aws_ssm_parameter" "postgres_host" {
  name  = "/${var.prefix}/postgres/DB_HOST"
  type  = "String"
  value = aws_db_instance.postgres.address
}

resource "aws_ssm_parameter" "postgres_port" {
  name  = "/${var.prefix}/postgres/DB_PORT"
  type  = "String"
  value = aws_db_instance.postgres.port
}

# alert if DB CPU is above 80% for 5 minutes
resource "aws_cloudwatch_metric_alarm" "db_cpu_high" {
  alarm_name          = "${var.prefix}-postgres-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS Postgres CPU utilization is above 80% for 5 minutes"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }
  alarm_actions = [var.alarm_topic_arn]
}