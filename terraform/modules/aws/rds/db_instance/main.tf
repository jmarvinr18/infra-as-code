resource "aws_db_instance" "this" {
  identifier           = var.identifier
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  db_subnet_group_name = var.db_subnet_group_name
  skip_final_snapshot  = var.skip_final_snapshot
  deletion_protection  = var.deletion_protection 

  vpc_security_group_ids = [for sg in var.vpc_security_group_ids: sg]

}