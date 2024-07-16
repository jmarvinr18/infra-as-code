module "sg_module" {
  source = "../../../../../modules/aws/sg"
  security_group_name = "my security group"
}

module "ec2_module" {
  source = "../../../../../modules/aws/ec2"
  
}

resource "aws_instance" "web" {
  ami                    = "ami-07bf1d1b4c1225623"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.sg_module.sg_id]
}