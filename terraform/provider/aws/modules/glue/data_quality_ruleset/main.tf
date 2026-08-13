resource "aws_glue_data_quality_ruleset" "this" {
  name    = var.name
  ruleset = var.ruleset

  target_table {
    database_name = var.database_name
    table_name    = var.table_name
  }
}
