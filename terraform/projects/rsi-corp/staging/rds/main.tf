
module "subnet_group" {
  source     = "../../../../modules/aws/rds/subnet_group"
  name       = "terraform-subnet-group"
  subnet_ids = data.aws_subnets.this.ids
}

module "parameter_group" {
  source     = "../../../../modules/aws/rds/parameter_group"
  name       = var.parameter_name
  family     = var.family
  parameters = var.parameters
}

module "db_instance" {
  source                 = "../../../../modules/aws/rds/db_instance"
  db_name                = var.db_name
  identifier             = var.identifier
  instance_class         = var.instance_class
  parameter_group_name   = module.parameter_group.name
  db_subnet_group_name   = module.subnet_group.name
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.username
  password               = var.password
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = false
  vpc_security_group_ids = data.aws_security_groups.this.ids
}