resource "aws_security_group" "ec2_sg" {
  name = var.security_group_name
  tags = var.tags
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for i, rule in var.ingress_rules : i => rule }

  type        = "ingress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  security_group_id = aws_security_group.ec2_sg.id

}

resource "aws_security_group_rule" "egress" {
  for_each = { for i, rule in var.egress_rules : i => rule }

  type        = "egress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  security_group_id = aws_security_group.ec2_sg.id

}