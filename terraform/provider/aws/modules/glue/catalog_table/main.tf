resource "aws_glue_catalog_table" "this" {
  name          = var.name
  database_name = var.database_name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = var.classification
    "EXTERNAL"       = "TRUE"
  }

  storage_descriptor {
    location      = var.s3_location
    input_format  = var.input_format
    output_format = var.output_format

    ser_de_info {
      serialization_library = var.serialization_library
      parameters = {
        "serialization.format" = "1"
      }
    }

    dynamic "columns" {
      for_each = var.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }
}
