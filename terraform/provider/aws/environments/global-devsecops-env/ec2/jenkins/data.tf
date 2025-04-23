data "aws_security_groups" "existing_sg" {
  tags = var.tags
}

# data "aws_key_pair" "crm-key" {
#   key_name = var.key_name
# }