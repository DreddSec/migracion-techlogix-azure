variable "location" { type = string }
variable "resource_group" { type = string }
variable "project" { type = string }
variable "environment" { type = string }

variable "mysql_admin_user" {
  type    = string
  default = "wpuser"
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_location" {
  type    = string
  default = "northeurope"
}
