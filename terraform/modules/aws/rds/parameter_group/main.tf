resource "aws_db_parameter_group" "this" {
  name   = var.name
  family = var.family

  dynamic "parameter" {
    for_each = [for param in var.parameters : param if param.name != ""]

    content {
        name  = parameter.value.name
        value = parameter.value.value
    }
  }  
}