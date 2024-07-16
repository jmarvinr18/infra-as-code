resource "aws_key_pair" key_name {
  key_name   = var.key_name
  public_key = file("${var.KEY_PATH}/provisioner-key.pub")
}