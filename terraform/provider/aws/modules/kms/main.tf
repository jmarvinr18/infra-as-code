resource "aws_kms_key" "this" {
  description             = var.description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  tags                    = var.tags

  policy = var.policy
}

resource "aws_kms_alias" "this" {
  name          = var.kms_alias_name
  target_key_id = aws_kms_key.this.key_id
}

