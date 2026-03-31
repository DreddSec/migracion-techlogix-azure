variable "location" { type = string }
variable "resource_group" { type = string }
variable "project" { type = string }
variable "environment" { type = string }

variable "alert_email" {
  type        = string
  description = "Email para recibir alertas"
}

variable "container_app_id" {
  type        = string
  description = "ID del Container App Environment"
}
