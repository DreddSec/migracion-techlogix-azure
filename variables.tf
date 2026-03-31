variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "westeurope"
}

variable "project" {
  description = "Migracion de la infraestructura de red TechLogix"
  type        = string
  default     = "techlogix"
}

variable "environment" {
  description = "Entorno"
  type        = string
  default     = "prod"
}

variable "entra_domain" {
  type        = string
  description = "ultimicrogrooving578passmai.onmicrosoft.com"
}

variable "default_password" {
  type        = string
  sensitive   = true
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_location" {
  type    = string
  default = "northeurope"
}

variable "alert_email" {
  type        = string
  description = "Email para alertas de Azure Monitor"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}
