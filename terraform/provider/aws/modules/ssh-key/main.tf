resource "tls_private_key" "rsa" {
  algorithm = var.algorithm
  rsa_bits  = var.bits
}

resource "aws_key_pair" "rsa" {
  key_name   = var.name
  # public_key = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlT4LMW9mhaaWovxEJET8dbIlE1QyZ88jo2/Zcw/SFX adrianmillena@Adrians-MacBook-Pro.local"
  public_key = tls_private_key.rsa.public_key_openssh
}