# variables for RDS Instance
identifier           = "terraform-rds-mysl"
vpc_id               = "vpc-0211fa383b4de3a2d"
db_name              = "test"
instance_class       = "db.t3.micro"
parameter_group_name = "marvin-params"
engine               = "mysql"
engine_version       = "8.0"
username             = "test_user"
password             = "S31D23dwWM"
skip_final_snapshot  = true
deletion_protection  = false


# variables for parameter group
parameter_name = "marvin-params"
family         = "mysql8.0"
parameters = [{
  name  = "max_connections"
  value = "200"
  },
  {
    name  = "innodb_buffer_pool_size"
    value = "268435456"
  },
]