resource "aws_db_parameter_group" "mysql_cdc_parameter_group" {
  name = "mysql-cdc-parameter-group"

  family = "mysql5.7"
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
}

resource "aws_db_instance" "db" {
  name                    = var.db_name
  allocated_storage       = var.db_allocated_storage
  storage_type            = var.db_storage_type
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [var.vpc_rds_security_group_id]
  skip_final_snapshot     = var.db_skip_final_snapshot
  parameter_group_name    = aws_db_parameter_group.mysql_cdc_parameter_group.name
  backup_retention_period = 1
}
