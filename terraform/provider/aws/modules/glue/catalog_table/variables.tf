variable "name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "s3_location" {
  type = string
}

variable "classification" {
  type    = string
  default = "json"
}

variable "input_format" {
  type    = string
  default = "org.apache.hadoop.mapred.TextInputFormat"
}

variable "output_format" {
  type    = string
  default = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
}

variable "serialization_library" {
  type    = string
  default = "org.openx.data.jsonserde.JsonSerDe"
}

variable "columns" {
  type = list(object({
    name = string
    type = string
  }))
  default = []
}
