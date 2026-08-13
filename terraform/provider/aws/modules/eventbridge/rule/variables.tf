variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "event_bus_name" {
  type    = string
  default = "default"
}

variable "event_pattern" {
  type    = string
  default = null
}

variable "schedule_expression" {
  type    = string
  default = null
}

variable "state" {
  type    = string
  default = "ENABLED"
}

variable "tags" {
  type    = map(string)
  default = {}
}
