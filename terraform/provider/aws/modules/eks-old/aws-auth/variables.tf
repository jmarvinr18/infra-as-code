variable "admins" {
  default = [
    "drey.millena",
    "marvin.ramoda"
  ]
}

variable "devs" {
  default = [
    "jimboy.balan"
  ]
}

variable "roles" {
  default = [
    "AWSReservedSSO_AdministratorAccess_9d238ad90f02dab4"
  ]
}

variable "cluster" {
  type    = string
  default = ""
}