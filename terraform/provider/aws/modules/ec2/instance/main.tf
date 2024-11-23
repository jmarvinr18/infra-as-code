
resource "aws_instance" "this" {
  ami                  = var.amis
  instance_type        = var.instance_type
  availability_zone    = var.zone
  key_name             = var.key_pair
  subnet_id            = var.subnet_id
  iam_instance_profile = var.iam_instance_profile
  security_groups      = var.security_groups
  associate_public_ip_address = var.associate_public_ip_address
  # vpc_security_group_ids = var.vpc_security_group_ids

  tags = var.tags

  connection {
    user        = var.user
    private_key = file(var.private_key)
    host        = self.public_ip
  }
}


