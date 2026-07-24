resource "aws_dynamodb_table" "this" {
  name           = var.ddb_name
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key

  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }

  lifecycle {
    prevent_destroy = true
  }
}
