resource "aws_eip" "this" {
  domain = var.domain
  tags = var.tags

}