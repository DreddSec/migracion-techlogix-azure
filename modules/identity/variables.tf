variable "domain" {
  type        = string
  description = "Dominio de Entra ID (ultimicrogrooving578passmai.onmicrosoft.com)"
}

variable "default_password" {
  type        = string
  sensitive   = true
  description = "Password inicial para todos los usuarios"
}
