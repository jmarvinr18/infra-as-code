variable "ddb_name" {
  description = "The name of the Dynamo DB"
  type        = string
}

variable "read_capacity" {
  type        = string
}

variable "write_capacity" {
  type        = string
}

variable "hash_key" {
  type        = string
}

variable "attribute_name" {
  type        = string
}

variable "attribute_type" {
  type        = string
}

# variable "prevent_destroy" {
#   type        = bool
# }

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
}

